@AbapCatalog.sqlViewName: 'ZHBIBOOKSUPPTM3'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Flight Ref. Scenario: Booking Supplement (Managed)'

define view zhb_I_BOOKINGSUPPLEMENT_TM3
  as select from zhbbooksup_tm3

  association        to parent zhb_I_BOOKING_TM3 as _Booking        on  $projection.travel_id  = _Booking.travel_id
                                                                    and $projection.booking_id = _Booking.booking_id

  association [1..*] to /DMO/I_SupplementText    as _SupplementText on  $projection.supplement_id = _SupplementText.SupplementID
  association [0..*] to /DMO/I_CURRENCYTEXT      as _CurrencyText   on  $projection.currency_code = _CurrencyText.Currency
{
  key travel_id,
  key booking_id,
  key booking_supplement_id,
      supplement_id,
      price,
      currency_code,

      /* Associations */
      _Booking,

      _CurrencyText,
      _SupplementText
}
