@EndUserText.label: 'Flight Ref.Scen.: Booking Supplement (Managed) Projection'
@AccessControl.authorizationCheck: #NOT_REQUIRED

@UI: { headerInfo: { typeName: 'Booking Supplement',
                     typeNamePlural: 'Booking Supplements',
                     title: { type: #STANDARD, label: 'Booking Supplement', value: 'Booking_Supplement_ID' } } }

@Search.searchable: true

define view entity zhb_C_BOOKINGSUPPLEMENT_TM3
  as projection on zhb_I_BookingSupplement_TM3
{
      @UI.facet: [ { id:            'BookingSupplement',
                     purpose:       #STANDARD,
                     type:          #IDENTIFICATION_REFERENCE,
                     label:         'Booking Supplement',
                     position:      10 }
                        ,
                   { id:              'PriceHeader',
                     type:            #DATAPOINT_REFERENCE,
                     purpose:         #HEADER,
                     targetQualifier: 'Price',
                     label:           'Price',
                     position:        20 }
                    ]

  key travel_id             as Travel_ID,

  key booking_id            as Booking_ID,

      @UI: { lineItem:       [ { position: 10 } ],
             identification: [ { position: 10 } ] }
  key booking_supplement_id as Booking_Supplement_ID,

      @UI: { lineItem:       [ { position: 20 } ],
             identification: [ { position: 20 } ] }
      @Consumption.valueHelpDefinition: [{entity: {name: '/DMO/I_SUPPLEMENT', element: 'SupplementID' },
                                          additionalBinding: [{ localElement: 'Price',        element: 'Price'},
                                                              { localElement: 'Currency_Code', element: 'CurrencyCode'}]}]
      @ObjectModel.text.element: ['SupplementTextDescription']
      supplement_id         as Supplement_ID,
      
      _SupplementText.Description as SupplementTextDescription : localized,

      @UI: { lineItem:       [ { position: 30, importance: #HIGH } ],
             identification: [ { position: 30 } ],
             dataPoint:      { title: 'Price' } }
      @Semantics.amount.currencyCode: 'Currency_Code'
      price                 as Price,

      @Semantics.currencyCode: true
      @Consumption.valueHelpDefinition: [{ entity: {name: 'I_Currency', element: 'Currency' }}]
      currency_code         as Currency_Code,

      /* Associations */
      _Booking : redirected to parent zhb_C_Booking_TM3,

      _CurrencyText,
      _SupplementText
}
