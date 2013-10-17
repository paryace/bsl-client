define(['zepto', 'underscore','text!com.csair.base/airport/airport-list-template.html', 'backbone',"i18n!com.csair.base/airport/nls/mbp"], 
    function($, _, alTemplate,Backbone,Locale){

    var list;
    var segment;
    var item = {};
    var AirportList = Backbone.View.extend({
            events: {

            },

            config: { 
                /*提取到父类*/
                observers: [],
                /*自有*/
                inputName:'arrport',
                url:"./airports-china.json",
                autoload : true,
                pageParam: 'beginIndex', 
                pageSize :10,
                iScroll :false,
                listId:"airports-list",
                showElemType:"input",
                showElemClass:'',
                hideTarget:null
            },

            initialize: function() {

                //获取传入参数
                if (arguments && arguments.length > 0) {
                    var config = arguments[0];
                    var obj = new Object();
                    for(var configKey in this.config){
                        obj[configKey] = this.config[configKey];
                    }
                    for(var argkey in config){
                        obj[argkey] = config[argkey];
                    }
                    this.config = obj;
                }

                if(!this.el.querySelector(this.config.listId)){
                    this.render();
                }

            },
            rendered : function() {
                return this.jqObject.get(0).nodeName == "DIV";
            },
            render : function() {
            	
                var me = this;

			    var realDiv = $(this.el);

                if(this.config.inputName=="depport"|| this.config.inputName=="arrport"|| this.config.inputName=="mileageFrom"||this.config.inputName=="mileageTo"||this.config.inputName=='myEarningStdFrom'||this.config.inputName=='myEarningStdArr'||this.config.inputName=='RedemptionStddepport'||this.config.inputName=='RedemptionStdarrport'){
                	$(this.config.parent).find('#city').show();
                }else{
                	$(this.config.parent).find('#city').hide();
                }
                
                //$(this.config.parent).find('#list-page').css('padding-top','102px');

                //国内,国际切换
                segment.unbind('Segment:change');
                segment.bind('Segment:change',function(comp){
                    var value = comp.getValue();
                    // var filterValue = list.getfilterValue();
                    // list.config['filterStr'] = filterValue;
                    if(value == "domestic"){
                        list.config['url'] = "../com.csair.base/airport/airports-china.json";
                    }else{
                        list.config['url'] = "../com.csair.base/airport/airports-internation.json";
                    }
                    list.setRequestParams({
                    });
                });

                var me = this;

                //选择城市事件
                var id = me.config['id'];

                $("#backBtnClick").click(function(){

                    
                        Backbone.history.navigate("/", {
                            trigger: true
                        });
                });

                list.unbind('List:select');
                list.bind('List:select', function(list, data) {
                    //console.info(data);
                    var target = Piece.Session.loadObject("cityStoreTarget");
                    Piece.Session.saveObject('cityStore' + target,Locale.language == "zh-cn" ? data.zh_cn : data.en_us);

                    window.history.back();

                });
            }
        },

        

        {   
            parseConfig: function(element, attNameList){

                var jqObject = $(element);

                var config = {};
                for (var i = 0; i < attNameList.length; i++) {
                    var key = attNameList[i];
                    var value = jqObject.attr(key);
                    if(value) config[key] = value;
                }

                return config;
            },
            compile: function(el){
                var me = this;
                return _.map($(el).find("AirportList"), function(tag){

                    var config = me.parseConfig(tag,['id','inputName','url','autoload','pagesetParam','iScroll','listId','onItemSelect','hideTarget','showElemType','showElemClass','class','locale']);
                    var realDiv = document.createElement('div');
                    realDiv.setAttribute('id', config.id);

                    if(config.class){
                        $(realDiv).addClass(config.class);
                    }else{
                        $(realDiv).addClass('cube-form-textfield');
                    }

                    var showInput
                    //插入隐藏iput
                    if(config.showElemType == "div"){
                      showInput = $("<div class='airport-showdiv' >").attr('id',config['id'] + '-showInput');
                    }else{
                      showInput = $("<input class='airport-showinput' type='text' style='background:#FFF;cursor:pointer' readonly='readonly'></input>").attr('id',config['id'] + '-showInput');
                    }
                    //为显示填充元素添加样式
                    if(config.showElemClass){
                        var classList = config.showElemClass.split(" ");
                        for(var i = 0; i < classList.length; i++){
                            showInput.addClass(classList[i]);
                        }
                    }
                    showInput.appendTo($(realDiv));

                    var submitInput = $("<input type='hidden'></input>").attr('id',config['id'] + '-submitInput');
                    if(config.inputName){
                        submitInput.attr('name',config.inputName);
                    }
                    submitInput.appendTo($(realDiv));
                    //覆盖AirportList标签
                    $(tag).replaceWith(realDiv);
                    config['el'] = realDiv;
                    var listWrapper = el.querySelector('#airports-window');
                    //改格式xx-xx为xx_xx
                    if(!config['locale'])
                        config['locale'] = "zh-cn";

                    if(config.hideTarget)
                        config.hideTarget = config.hideTarget.split(" ");
                    
                    if(!listWrapper){    
                        //组合成模版格式,让下面list填充数据 
                        item.lang = {};
                        for(var localeKey in Locale){
                            item.lang[localeKey] = Locale[localeKey];
                        }
                        item.lang.locale = "<%="+item.lang.locale.split("-")[0]+"_"+item.lang.locale.split("-")[1]+"%>";
                        //给template加上国际化配置
                        var windowDiv = $(_.template(alTemplate,item));
                        windowDiv.appendTo(el);
						config['parent'] = el;
                        // windowDiv.hide();

                        var lists =Piece.List.compile(el);
                        var segments =Piece.Segment.compile(el);

                        for(var i = 0; i < segments.length; i++){
                            if(segments[i].el.id == "city"){
                                segment = segments[i];
                            }
                        }
                        for(var i = 0; i < lists.length; i++){
                            if(lists[i].id == "airports-list"){
                                list = lists[i];
                            }
                        }
                        //恢复原有格式
                        item.lang.locale = item.lang.locale.split("<%=")[1].split("%>")[0];
                    }

                    return new AirportList(config);
                });
            }
    })

    return AirportList;
});