@EndUserText.label: 'Flight Ref.Scen.: Booking (Managed) Projection'
@AccessControl.authorizationCheck: #NOT_REQUIRED

@UI: { headerInfo: { typeName: 'Booking',
                     typeNamePlural: 'Bookings',
                     title: { type: #STANDARD, label: 'Booking', value: 'Booking_ID' },
                     description: { label: 'Flight', value: '_Connection.Description' } } }

@Search.searchable: true

define view entity zhb_C_BOOKING_TM3
  as projection on zhb_I_Booking_TM3
{
      @UI.facet: [ { id:            'Booking',
                        purpose:       #STANDARD,
                        type:          #IDENTIFICATION_REFERENCE,
                        label:         'Booking',
                        position:      10 },
                      { id:            'BookingSupplement',
                        purpose:       #STANDARD,
                        type:          #LINEITEM_REFERENCE,
                        label:         'Booking Supplement',
                        position:      20,
                        targetElement: '_BookSuppl'},

                      { id:              'CustomerHeader',
                        type:            #CONTACT_REFERENCE,
                        purpose:         #HEADER,
                        targetElement:   '_Customer',
                        label:           'Customer',
                        position:        10
                      },
                      { id:              'FlightPriceHeader',
                        type:            #DATAPOINT_REFERENCE,
                        purpose:         #HEADER,
                        targetQualifier: 'Flight_Price',
                        label:           'Flight Price',
                        position:        20
                      } ]

      @UI: { identification: [ { position: 10 } ] }
  key travel_id               as Travel_ID,

      @UI: { lineItem:       [ { position: 20, importance: #HIGH } ],
             identification: [ { position: 20 },
                               { type: #FOR_ACTION, dataAction: 'bookingsupplement_cba', label: 'Create Booking Supplement with defaults' } ] }
      @Search.defaultSearchElement: true
  key booking_id              as Booking_ID,

      @UI: { lineItem:       [ { position: 30, importance: #HIGH } ],
             identification: [ { position: 30 } ] }
      booking_date            as Booking_Date,

      @UI: { lineItem:       [ { position: 40, importance: #HIGH } ],
             identification: [ { position: 40 } ] }
      @Consumption.valueHelpDefinition: [{entity: {name: '/DMO/I_Customer', element: 'CustomerID' }}]
      @ObjectModel.text.element: ['CustomerName']
      customer_id             as Customer_ID,

      _Customer.LastName      as CustomerName,

      @UI: { lineItem:       [ { position: 50, importance: #HIGH } ],
             identification: [ { position: 50 } ] }
      @Consumption.valueHelpDefinition: [{entity: {name: '/DMO/I_CARRIER', element: 'AirlineID' }}]
      @ObjectModel.text.element: ['CarrierName']
      carrier_id              as Carrier_ID,

      _Carrier.Name           as CarrierName,

      @UI: { lineItem:       [ { position: 60, importance: #HIGH } ],
             identification: [ { position: 60 } ] }
      @Consumption.valueHelpDefinition: [{entity: {name: '/DMO/I_Flight', element: 'ConnectionID' },
                                          additionalBinding: [{ localElement: 'Flight_Date',   element: 'FlightDate'},
                                                              { localElement: 'Carrier_ID', element: 'AirlineID'},
                                                              { localElement: 'Flight_Price',  element: 'Price' },
                                                              { localElement: 'Currency_Code', element: 'CurrencyCode' }]}]
      @ObjectModel.text.element: ['ConnectionDescription']
      connection_id           as Connection_ID,

      _Connection.Description as ConnectionDescription,


      @UI: { lineItem:       [ { position: 70, importance: #HIGH } ],
             identification: [ { position: 70 } ] }
      @Consumption.valueHelpDefinition: [{entity: {name: '/DMO/I_Flight', element: 'FlightDate' },
                                          additionalBinding: [{ localElement: 'Connection_ID', element: 'ConnectionID'},
                                                              { localElement: 'Carrier_ID',    element: 'AirlineID'},
                                                              { localElement: 'Flight_Price',  element: 'Price' },
                                                              { localElement: 'Currency_Code', element: 'CurrencyCode' }]}]
      flight_date             as Flight_Date,

      @UI: { lineItem:       [ { position: 80, importance: #HIGH } ],
             identification: [ { position: 80 } ],
             dataPoint:      { title: 'Flight Price' } }
      @Semantics.amount.currencyCode: 'Currency_Code'
      flight_price            as Flight_Price,

      @Semantics.currencyCode: true
      @Consumption.valueHelpDefinition: [{entity: {name: 'I_Currency', element: 'Currency' }}]
      currency_code           as Currency_Code,

      /* Associations */
      _Travel    : redirected to parent zhb_C_Travel_TM3,
      _BookSuppl : redirected to composition child zhb_C_BookingSupplement_TM3,

      _Customer,
      _Carrier,
      _Connection

}
