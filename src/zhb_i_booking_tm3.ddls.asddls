@AbapCatalog.sqlViewName: 'ZHBBOOKINGTM3'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Flight Ref. Scenario: Booking (Managed)'

define view zhb_I_BOOKING_TM3
  as select from zhbbooking_tm3

  association        to parent zhb_I_Travel_TM3     as _Travel       on  $projection.travel_id = _Travel.travel_id

  composition [0..*] of zhb_I_BookingSupplement_TM3 as _BookSuppl

  association [1..1] to /DMO/I_Customer_TU           as _Customer     on  $projection.customer_id   = _Customer.CustomerID
  association [1..1] to /DMO/I_Carrier               as _Carrier      on  $projection.carrier_id    = _Carrier.AirlineID
  association [1..1] to /DMO/I_Connection_TUM        as _Connection   on  $projection.carrier_id    = _Connection.CarrierID
                                                                      and $projection.connection_id = _Connection.ConnectionID
  association [0..*] to /DMO/I_CURRENCYTEXT          as _CurrencyText on  $projection.currency_code = _CurrencyText.Currency
{
  key travel_id,
  key booking_id,

      booking_date,
      customer_id,
      carrier_id,
      connection_id,
      flight_date,
      flight_price,
      currency_code,

      /* Associations */
      _Travel,
      _BookSuppl,

      _Customer,
      _Carrier,
      _Connection,
      _CurrencyText
}
