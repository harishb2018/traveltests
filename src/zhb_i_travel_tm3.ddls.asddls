@AbapCatalog.sqlViewName: 'ZHBTRAVELTM3'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Flight Ref. Scenario: Travel (Managed)'
        
@ObjectModel.semanticKey: ['travel_id']
@ObjectModel.representativeKey: 'travel_id'
 
define root view zhb_I_TRAVEL_TM3
  as select from zhbtravel_tm3 as Travel 
 
  composition [0..*] of zhb_I_Booking_TM3 as _Booking

  association [1..1] to /DMO/I_Agency_TU   as _Agency       on $projection.agency_id = _Agency.AgencyID
  association [1..1] to /DMO/I_Customer_TU as _Customer     on $projection.customer_id = _Customer.CustomerID
  association [0..*] to I_CurrencyText     as _CurrencyText on $projection.currency_code = _CurrencyText.Currency
{
 
  key travel_id,
      agency_id,
      customer_id,
      begin_date,
      end_date,

      @Semantics.amount.currencyCode: 'Currency_Code'
      booking_fee,

      @Semantics.amount.currencyCode: 'Currency_Code'
      total_price,

      currency_code,
      description,
      status,

      @Semantics.user.createdBy: true
      createdby,
      @Semantics.systemDateTime.createdAt: true
      createdat,
      @Semantics.user.lastChangedBy: true
      lastchangedby,
      @Semantics.systemDateTime.lastChangedAt: true
      lastchangedat,

      /* Associations */
      _Booking,
      _Agency,
      _Customer,
      _CurrencyText
}
