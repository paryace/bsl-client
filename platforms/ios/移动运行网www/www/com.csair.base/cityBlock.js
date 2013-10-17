define([  'text!com.csair.base/cityBlock.html','com.csair.base/airports-list'
    ], function(demoIndexTemplate,AirportList){
    var View = Piece.View.extend({

        id: 'detailview',

        events: {
            


        },

        bindings: {

            // "Segment:change io": "onIOChange",
            // "List:select flightstatus-list": "onItemSelect"
        },
        
        render: function(){
            $(this.el).html(demoIndexTemplate);
            AirportList.compile(this.el);
            // $(this).append(template);
            Piece.View.prototype.render.call(this);
            return this;
        },

        onShow:function(){
            // this.cityDialog  = $(this.el)
            //                     .listSliderNavDoubleWindow(SliderTemplateB,
            //                                             CityData,
            //                                             CityDataI);
            // console.log(this.cityDialog);

        },
        cityDialog: null,

        showAirport: function(e) {
           //  var targetId = $(e.currentTarget).attr('target');
           //  if (!targetId) {
             //      targetId = $(e.currentTarget).attr('id');
           //  }
           // this.cityDialog.setTarget(targetId);
        },
        
    });

    return View;
});