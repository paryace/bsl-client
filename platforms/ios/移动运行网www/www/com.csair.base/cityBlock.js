define([  'text!com.csair.base/cityBlock.html','text!com.csair.base/IncityBlock.html','text!com.csair.base/chcityBlock.html'
    ], function(cityTemplate,IncityTemplate,ChcityTemplate){
    var isCity;
    var segment;
    var View = Piece.View.extend({

        id: 'detailview',


        events: {
            


        },

        bindings: {

        },
        
        render: function(){
            $(this.el).html(cityTemplate);
            Piece.View.prototype.render.call(this);
            var segments =Piece.Segment.compile(this.el);
            for(var i = 0; i < segments.length; i++){
                if(segments[i].el.id == "city"){
                    segment = segments[i];
                }
            }
            var me  = this;
            segment.unbind('Segment:change');
            segment.bind('Segment:change',function(comp){
                var value = comp.getValue();
                me.initList();
            });
            return this;
        },

        onShow:function(){
            var me = this;
            isCity = false;
            this.initList();
            var searchInput = $('#searchInput');
            searchInput.css('margin-bottom', '0px');
            searchInput.css('padding-left', '8px');
            searchInput.attr('type', 'text');
            searchInput.bind('touchend input', function(e) {
                window.scrollTo(0, 0);
                var inputVal = searchInput.val();
                me.filterChildren(inputVal);
            });
        },

        initList:function(){
            var me = this;
            isCity == true ? $(me.el).find('#airports-list').html(IncityTemplate) : $(me.el).find('#airports-list').html(ChcityTemplate);
            isCity == true ? isCity = false : isCity = true;
            me.bindItems();
        },

        filterChildren: function(keyWord) {
            var contentScroller = this.$(".contentScroller");
            if (keyWord) {
                contentScroller.find("li[filter-keyword]").hide();
                this.$('#' + 'airports-list' + ' li[filter-keyword*="' + keyWord.toLowerCase() + '"]').show();
            } else {
                contentScroller.find("li[filter-keyword]").show();
            }
        },

        bindItems:function(){
            $('.cube-list-item').unbind('click');
            $('.cube-list-item').bind('click',function(cell){
                var target = Piece.Session.loadObject("cityStoreTarget");
                Piece.Session.saveObject('cityStore' + target,$(cell.target).find('.city_name').html());
                window.history.back();
            });
        }
        
    });

    return View;
});