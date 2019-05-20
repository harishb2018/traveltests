@EndUserText.label: 'Flight Ref.Scen.: Travel (Managed) Projection'
@AccessControl.authorizationCheck: #NOT_REQUIRED

@UI: { headerInfo: { typeName: 'Travel',
                     typeNamePlural: 'Travels',
                     title: { type: #STANDARD, label: 'Travel', value: 'Travel_ID' },
                     description: { label: 'Description:', value: 'Description' } },

       presentationVariant: [{ sortOrder: [{ by: 'Travel_ID',
                                             direction: #DESC }] }] }

@Search.searchable: true

define root view entity zhb_C_TRAVEL_TM3
  as projection on zhb_I_Travel_TM3
{
          @UI.facet: [ { id:              'Travel',
                         purpose:         #STANDARD,
                         type:            #COLLECTION,
                         label:           'Travel',
                         position:        10 },
                       { id:              'Booking',
                         purpose:         #STANDARD,
                         type:            #LINEITEM_REFERENCE,
                         label:           'Booking',
                         position:        20,
                         targetElement:   '_Booking'},

                       { id:              'AgencyHeader',
                         type:            #CONTACT_REFERENCE,
                         purpose:         #HEADER,
                         targetElement:   '_Agency',
                         label:           'Agency',
                         position:        10
                       },
                       { id:              'CustomerHeader',
                         type:            #CONTACT_REFERENCE,
                         purpose:         #HEADER,
                         targetElement:   '_Customer',
                         label:           'Customer',
                         position:        15
                       },
                       { id:              'PriceHeader',
                         type:            #DATAPOINT_REFERENCE,
                         purpose:         #HEADER,
                         targetQualifier: 'Total_Price',
                         label:           'Total Price',
                         position:        20
                       },

                       { id:              'General',
                         type:            #FIELDGROUP_REFERENCE,
                         parentId:        'Travel',
                         label:           'General Data',
                         targetQualifier: 'General',
                         position:        10
                       },
                       { id:              'Dates',
                         type:            #FIELDGROUP_REFERENCE,
                         parentId:        'Travel',
                         label:           'Travel Information',
                         targetQualifier: 'Dates',
                         position:        20
                       },
                       { id:              'Monetary',
                         type:            #FIELDGROUP_REFERENCE,
                         parentId:        'Travel',
                         label:           'Monetary Data',
                         targetQualifier: 'Monetary',
                         position:        30
                       }
                     ]

          @UI: { lineItem:       [ { position: 10, importance: #HIGH } ],
                 identification: [ { position: 10 } ],
                 fieldGroup:     [ { position: 10, qualifier: 'General' }] }
          @Search.defaultSearchElement: true
  key     travel_id          as Travel_ID,

          @UI: { lineItem:       [ { position: 20, label: 'Agency', importance: #HIGH, type: #AS_CONTACT, value: '_Agency' } ],
                 identification: [ { position: 20 } ],
                 fieldGroup:     [ { position: 20, qualifier: 'General' }],
                 selectionField: [ { position: 10 } ] }
          @Search.defaultSearchElement: true
          @Consumption.valueHelpDefinition: [{ entity: {name: '/DMO/I_AGENCY_TU', element: 'AgencyID' }}]
          @ObjectModel.text.element: ['AgencyName']
          agency_id          as Agency_ID,

          _Agency.Name       as AgencyName,

          @UI: { lineItem:       [ { position: 30, label: 'Customer', importance: #HIGH, type: #AS_CONTACT, value: '_Customer' } ],
                 identification: [ { position: 30 } ],
                 fieldGroup:     [ { position: 30, qualifier: 'General' }],
                 selectionField: [{ position: 20 }]}
          @Search.defaultSearchElement: true
          @Consumption.valueHelpDefinition: [{ entity: {name: '/DMO/I_Customer_TU', element: 'CustomerID' }}]
          @ObjectModel.text.element: ['CustomerName']
          customer_id        as Customer_ID,

          _Customer.LastName as CustomerName,

          @UI: { lineItem:       [ { position: 40 } ],
                 identification: [ { position: 40 } ],
                 fieldGroup:     [ { position: 10, qualifier: 'Dates' }],
                 selectionField: [ { position: 30 } ] }
          begin_date         as Begin_Date,

          @UI: { lineItem:       [ { position: 50 } ],
                 identification: [ { position: 50 } ],
                 fieldGroup:     [ { position: 20, qualifier: 'Dates' }],
                 selectionField: [ { position: 40 } ] }
          end_date           as End_Date,

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:/DMO/CL_I_TRAVEL_TM3_VE'
          @UI: { lineItem:       [ { position: 55, label:'Duration' } ],
                 identification: [ { position: 55, label:'Duration' } ],
                 fieldGroup:     [ { position: 25, qualifier: 'Dates', label:'Duration' }]}
          virtual DurationText: abap.char( 20 ),

          @Semantics.currencyCode: true
          @Consumption.valueHelpDefinition: [{ entity: {name: 'I_Currency', element: 'Currency' }} ]
          currency_code      as Currency_Code,

          @UI: { identification: [ { position: 60 } ],
                 fieldGroup:     [ { position: 20, qualifier: 'Monetary' }]  }
          @Semantics.amount.currencyCode: 'Currency_Code'
          booking_fee        as Booking_Fee,

          @UI: { identification: [ { position: 70 } ],
                 dataPoint:      { title: 'Total Price' },
                 fieldGroup:     [ { position: 10,  qualifier: 'Monetary' }]  }
          @Semantics.amount.currencyCode: 'Currency_Code'
          total_price        as Total_Price,

          @UI: { lineItem:       [ { position: 80 } ],
                 identification: [ { position: 80 } ],
                 fieldGroup:     [ { position: 30, qualifier: 'Dates' }]  }
          @Search.defaultSearchElement: true
          description        as Description,

          @UI: { lineItem:       [ { position: 90 },
                                   { type: #FOR_ACTION, dataAction: 'set_status_booked', label: 'Set Status to Booked' },
                                   { type: #FOR_ACTION, dataAction: 'create_prefilled_travel', label: 'Create Prefilled Travel' }],
                 identification: [ { position: 90 },
                                   { type: #FOR_ACTION, dataAction: 'booking_cba', label: 'Create Booking with defaults' }],
                 fieldGroup:     [ { position: 40, qualifier: 'General' }] }
          status             as Status,

          /* Associations */
          @Search.defaultSearchElement: true
          _Booking : redirected to composition child zhb_C_Booking_TM3,

          @Search.defaultSearchElement: true
          _Agency,
          @Search.defaultSearchElement: true
          _Customer,
          _CurrencyText
}
