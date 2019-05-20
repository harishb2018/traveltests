*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
CLASS lhc_travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS validate_agency FOR VALIDATION travel~validate_agency
      IMPORTING keys FOR travel.

    METHODS validate_customer FOR VALIDATION travel~validate_customer
      IMPORTING keys FOR travel.

    METHODS validate_dates FOR VALIDATION travel~validate_dates
      IMPORTING keys FOR travel.

    METHODS validate_status FOR VALIDATION travel~validate_status
      IMPORTING keys FOR travel.

    METHODS booking_cba FOR MODIFY
      IMPORTING keys FOR ACTION travel~booking_cba RESULT result.

    METHODS create_prefilled_travel FOR MODIFY
      IMPORTING keys FOR ACTION travel~create_prefilled_travel RESULT result.

    METHODS get_travel FOR MODIFY
      IMPORTING keys FOR ACTION travel~get_travel RESULT result.

    METHODS set_status_booked FOR MODIFY
      IMPORTING keys FOR ACTION travel~set_status_booked RESULT result.

    METHODS get_features FOR FEATURES
      IMPORTING keys REQUEST requested_features FOR travel RESULT result.

ENDCLASS.

CLASS lhc_travel IMPLEMENTATION.

  METHOD validate_agency.

    READ ENTITIES OF zhb_i_travel_tm3
       ENTITY travel FROM VALUE #( FOR <root_key> IN keys
                                         ( %key     = <root_key>
                                           %control = VALUE #( agency_id = cl_abap_behv=>flag_changed ) ) )
       RESULT DATA(lt_travel).

    DATA lt_agency TYPE SORTED TABLE OF /dmo/agency WITH UNIQUE KEY agency_id.

    " extract distinct non-initial agency ids
    lt_agency = CORRESPONDING #(  lt_travel DISCARDING DUPLICATES MAPPING agency_id = agency_id EXCEPT * ).
    DELETE lt_agency WHERE agency_id IS INITIAL.
    CHECK lt_agency IS NOT INITIAL.

    " check if they exist
    SELECT FROM /dmo/agency FIELDS agency_id
      FOR ALL ENTRIES IN @lt_agency
      WHERE agency_id = @lt_agency-agency_id
      INTO TABLE @DATA(lt_agency_db).

    " raise msg for non existing
    LOOP AT lt_travel INTO DATA(ls_travel).
      IF ls_travel-agency_id IS NOT INITIAL
         AND NOT line_exists( lt_agency_db[ agency_id = ls_travel-agency_id ] ).

        APPEND VALUE #(  travel_id = ls_travel-travel_id ) TO failed.
        APPEND VALUE #(  travel_id = ls_travel-travel_id
                         %msg = new_message( id = '/DMO/CM_FLIGHT_LEGAC' number = '001' v1 = ls_travel-agency_id severity = if_abap_behv_message=>severity-error )
                         %element-agency_id = cl_abap_behv=>flag_changed ) TO reported.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validate_customer.

    READ ENTITIES OF zhb_i_travel_tm3
       ENTITY travel FROM VALUE #( FOR <root_key> IN keys
                                         ( %key     = <root_key>
                                           %control = VALUE #( customer_id = cl_abap_behv=>flag_changed ) ) )
       RESULT DATA(lt_travel).

    DATA lt_customer TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.

    " extract distinct non-initial customer ids
    lt_customer = CORRESPONDING #(  lt_travel DISCARDING DUPLICATES MAPPING customer_id = customer_id EXCEPT * ).
    DELETE lt_customer WHERE customer_id IS INITIAL.
    CHECK lt_customer IS NOT INITIAL.

    " check if they exist
    SELECT FROM /dmo/customer FIELDS customer_id
      FOR ALL ENTRIES IN @lt_customer
      WHERE customer_id = @lt_customer-customer_id
      INTO TABLE @DATA(lt_customer_db).

    " raise msg for non existing
    LOOP AT lt_travel INTO DATA(ls_travel).
      IF ls_travel-customer_id IS NOT INITIAL
         AND NOT line_exists( lt_customer_db[ customer_id = ls_travel-customer_id ] ).

        APPEND VALUE #(  travel_id = ls_travel-travel_id ) TO failed.
        APPEND VALUE #(  travel_id = ls_travel-travel_id
                         %msg = new_message( id = '/DMO/CM_FLIGHT_LEGAC' number = '002' v1 = ls_travel-customer_id severity = if_abap_behv_message=>severity-error )
                         %element-customer_id = cl_abap_behv=>flag_changed ) TO reported.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validate_dates.

    READ ENTITIES OF zhb_i_travel_tm3
         ENTITY travel
                FROM VALUE #( FOR <root_key> IN keys
                                ( %key     = <root_key>
                                  %control = VALUE #( begin_date = cl_abap_behv=>flag_changed
                                                      end_date   = cl_abap_behv=>flag_changed
                                 ) ) )
               RESULT DATA(lt_travel_result).

    LOOP AT lt_travel_result INTO DATA(ls_travel_result).

      IF ls_travel_result-end_date < ls_travel_result-begin_date.  "end date before begin date?
        APPEND VALUE #( %key        = ls_travel_result-%key
                         travel_id  = ls_travel_result-travel_id
                      )                                                             TO failed.
        APPEND VALUE #(    %key     = ls_travel_result-%key
       %msg = new_message( id       = /dmo/cx_flight_legacy=>end_date_before_begin_date-msgid
                           number   = /dmo/cx_flight_legacy=>end_date_before_begin_date-msgno
                           v1       = ls_travel_result-begin_date
                           v2       = ls_travel_result-end_date
                           v3       = ls_travel_result-travel_id
                           severity = if_abap_behv_message=>severity-error
                         )
       %element-begin_date          = cl_abap_behv=>flag_changed
       %element-end_date            = cl_abap_behv=>flag_changed
                         )                                                          TO reported.

      ELSEIF ls_travel_result-begin_date < sy-datum.  "begin date needs to be in the future
        APPEND VALUE #( %key        = ls_travel_result-%key
                      travel_id     = ls_travel_result-travel_id
                      )                                                             TO failed.
        APPEND VALUE #(    %key = ls_travel_result-%key
       %msg = new_message( id       = /dmo/cx_flight_legacy=>begin_date_before_system_date-msgid
                           number   = /dmo/cx_flight_legacy=>begin_date_before_system_date-msgno
                           severity = if_abap_behv_message=>severity-error
                         )
       %element-begin_date          = cl_abap_behv=>flag_changed
       %element-end_date            = cl_abap_behv=>flag_changed
                         )                                                          TO reported.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validate_status.

    READ ENTITIES OF zhb_i_travel_tm3
         ENTITY travel
               FROM VALUE #( FOR <root_key> IN keys
                            ( %key     = <root_key>
                              %control = VALUE #( status = cl_abap_behv=>flag_changed
                          ) ) )
           RESULT DATA(lt_travel_result).

    LOOP AT lt_travel_result INTO DATA(ls_travel_result).

      CASE ls_travel_result-status.

        WHEN CONV /dmo/travel_status( /dmo/if_flight_legacy=>travel_status-booked    ).   " OK
        WHEN CONV /dmo/travel_status( /dmo/if_flight_legacy=>travel_status-cancelled ).   " OK
        WHEN CONV /dmo/travel_status( /dmo/if_flight_legacy=>travel_status-new       ).   " OK
        WHEN CONV /dmo/travel_status( /dmo/if_flight_legacy=>travel_status-planned   ).   " OK
        WHEN OTHERS.

          APPEND VALUE #( %key        = ls_travel_result-%key
                          travel_id   = ls_travel_result-travel_id
                        )                                                         TO failed.
          APPEND VALUE #( %key        = ls_travel_result-%key
          %msg = new_message( id      = /dmo/cx_flight_legacy=>status_is_not_valid-msgid
                             number   = /dmo/cx_flight_legacy=>status_is_not_valid-msgno
                             v1       = ls_travel_result-status
                             severity = if_abap_behv_message=>severity-error )
         %element-status              = cl_abap_behv=>flag_changed )              TO reported.
      ENDCASE.

    ENDLOOP.

  ENDMETHOD.

  METHOD booking_cba.

    DATA: lv_next_booking_id TYPE /dmo/booking_id.

    LOOP AT keys INTO DATA(ls_cba).

      READ ENTITY zhb_i_travel_tm3 BY \_booking
      FROM VALUE #( ( travel_id = ls_cba-travel_id
                      %control  = VALUE #( travel_id = cl_abap_behv=>flag_changed ) ) )
           RESULT   DATA(lt_read_result)
           FAILED   DATA(ls_read_failed)
           REPORTED DATA(ls_read_reported).

      IF lt_read_result IS INITIAL.
        lv_next_booking_id = '0001'.
      ELSE.
        SORT lt_read_result BY booking_id DESCENDING.
        lv_next_booking_id = lt_read_result[ 1 ]-booking_id + 1.
      ENDIF.

      MODIFY ENTITIES OF zhb_i_travel_tm3
      ENTITY  travel CREATE BY \_booking FROM VALUE #( ( travel_id = ls_cba-travel_id
                                                           %target = VALUE #( ( travel_id              = ls_cba-travel_id    "full key is required
                                                                                booking_id             = lv_next_booking_id  "full key is required
                                                                                booking_date           = cl_abap_context_info=>get_system_date( )
                                                                                customer_id            = '000001'
                                                                                carrier_id             = 'UA'
                                                                                connection_id          = '1537'
                                                                                flight_date            = cl_abap_context_info=>get_system_date( ) + 5
                                                                                flight_price           = '42.00'
                                                                                currency_code          = 'EUR'
                                                                                %control-travel_id     = cl_abap_behv=>flag_changed
                                                                                %control-booking_id    = cl_abap_behv=>flag_changed
                                                                                %control-booking_date  = cl_abap_behv=>flag_changed
                                                                                %control-customer_id   = cl_abap_behv=>flag_changed
                                                                                %control-carrier_id    = cl_abap_behv=>flag_changed
                                                                                %control-connection_id = cl_abap_behv=>flag_changed
                                                                                %control-flight_date   = cl_abap_behv=>flag_changed
                                                                                %control-flight_price  = cl_abap_behv=>flag_changed
                                                                                %control-currency_code = cl_abap_behv=>flag_changed
                                                                                ) ) ) )
      FAILED   DATA(ls_failed)
      MAPPED   DATA(ls_mapped)
      REPORTED DATA(ls_reported).

      APPEND LINES OF ls_failed-booking   TO failed-booking.
      APPEND LINES OF ls_reported-booking TO reported-booking.

      APPEND VALUE #( travel_id        = ls_cba-travel_id
                      %param-travel_id = ls_cba-travel_id ) TO result.
    ENDLOOP.

  ENDMETHOD.

  METHOD create_prefilled_travel.

    SELECT SINGLE * FROM zhbtravel_tm3 INTO @DATA(ls_travel).  "Just pick the 1st entry
    SELECT MAX( travel_id ) FROM /dmo/travel_tm3 INTO @DATA(lv_travel_id).

    LOOP AT keys INTO DATA(ls_travel_create).
      lv_travel_id = lv_travel_id + 1.
      MODIFY ENTITIES OF zhb_i_travel_tm3
             ENTITY travel CREATE FROM VALUE #( (
                               %cid                   = ls_travel_create-%cid
                               travel_id              = lv_travel_id
                               agency_id              = ls_travel-agency_id
                               customer_id            = ls_travel-customer_id
                               begin_date             = sy-datum
                               end_date               = sy-datum + 10
                               booking_fee            = ls_travel-booking_fee
                               total_price            = ls_travel-total_price
                               currency_code          = ls_travel-currency_code
                               description            = ls_travel-description
                               status                 = ls_travel-status
                               %control-travel_id     = cl_abap_behv=>flag_changed
                               %control-agency_id     = cl_abap_behv=>flag_changed
                               %control-customer_id   = cl_abap_behv=>flag_changed
                               %control-begin_date    = cl_abap_behv=>flag_changed
                               %control-end_date      = cl_abap_behv=>flag_changed
                               %control-booking_fee   = cl_abap_behv=>flag_changed
                               %control-total_price   = cl_abap_behv=>flag_changed
                               %control-currency_code = cl_abap_behv=>flag_changed
                               %control-description   = cl_abap_behv=>flag_changed
                               %control-status        = cl_abap_behv=>flag_changed
             ) )
             MAPPED   DATA(ls_mapped)
             FAILED   DATA(ls_failed)
             REPORTED DATA(ls_reported).

      APPEND LINES OF ls_failed-travel   TO failed-travel.
      APPEND LINES OF ls_reported-travel TO reported-travel.

      APPEND VALUE #( %cid             = ls_mapped-travel[ 1 ]-%cid
                      %param-travel_id = ls_mapped-travel[ 1 ]-travel_id ) TO result.
    ENDLOOP.

  ENDMETHOD.

  METHOD get_travel.

    READ ENTITY zhb_i_travel_tm3 FROM VALUE #( FOR travel IN keys
                                                      (  %key                              = travel-%key
                                                         %control = VALUE #( travel_id     = cl_abap_behv=>flag_changed
                                                                             agency_id     = cl_abap_behv=>flag_changed
                                                                             customer_id   = cl_abap_behv=>flag_changed
                                                                             begin_date    = cl_abap_behv=>flag_changed
                                                                             end_date      = cl_abap_behv=>flag_changed
                                                                             booking_fee   = cl_abap_behv=>flag_changed
                                                                             total_price   = cl_abap_behv=>flag_changed
                                                                             currency_code = cl_abap_behv=>flag_changed
                                                                             description   = cl_abap_behv=>flag_changed
                                                                             status        = cl_abap_behv=>flag_changed
                                                                             createdby     = cl_abap_behv=>flag_changed
                                                                             createdat     = cl_abap_behv=>flag_changed
                                                                             lastchangedby = cl_abap_behv=>flag_changed
                                                                             lastchangedat = cl_abap_behv=>flag_changed
                                                                           ) ) )
                                                      RESULT    DATA(lt_travel_result)
                                                      FAILED    failed
                                                      REPORTED  reported.

    LOOP AT lt_travel_result INTO DATA(ls_result).
      APPEND VALUE #( travel_id = ls_result-travel_id
                      %param    = CORRESPONDING #( ls_result )
                    ) TO result .
    ENDLOOP.

  ENDMETHOD.

  METHOD set_status_booked.

    MODIFY ENTITY zhb_i_travel_tm3 UPDATE FROM VALUE #( FOR travel IN keys
                                                         (  travel_id = travel-travel_id
                                                            status    = CONV  #( /dmo/if_flight_legacy=>travel_status-booked )
                                                            %control  = VALUE #( status = cl_abap_behv=>flag_changed         )
                                                         ) )
                                    MAPPED   mapped
                                    FAILED   failed
                                    REPORTED reported.
  ENDMETHOD.

  METHOD get_features.

    READ ENTITY zhb_i_travel_tm3 FROM VALUE #( FOR keyval IN keys
                                                      (  %key                   = keyval-%key
                                                         %control-travel_id     = cl_abap_behv=>flag_changed
                                                         %control-description   = cl_abap_behv=>flag_changed
                                                         %control-status        = cl_abap_behv=>flag_changed
                                                         %control-total_price   = cl_abap_behv=>flag_changed
                                                         %control-currency_code = cl_abap_behv=>flag_changed
                                                      ) )
                                                      RESULT    DATA(lt_travel_result)
                                                      FAILED    DATA(lt_travel_failed)
                                                      REPORTED  DATA(lt_travel_reported).

    result = VALUE #( FOR ls_travel IN lt_travel_result
                       ( %key = ls_travel-%key
                         %field-travel_id                    = if_abap_behv=>fc-f-read_only
                         %field-description                  = COND #( WHEN ls_travel-status = CONV /dmo/travel_status( /dmo/if_flight_legacy=>travel_status-booked )
                                                                       THEN if_abap_behv=>fc-f-read_only ELSE 0             )
                         %field-currency_code                = COND #( WHEN ls_travel-total_price IS NOT INITIAL
                                                                       THEN if_abap_behv=>fc-f-mandatory ELSE 0             )
                         %features-%action-set_status_booked = COND #( WHEN ls_travel-status = 'B'   "CONV /dmo/travel_status( /dmo/if_flight_legacy=>travel_status-booked )
                                                                       THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled   )
                      ) ).

  ENDMETHOD.

ENDCLASS.
