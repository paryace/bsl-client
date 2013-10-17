$.fn.listSliderNavDoubleWindow = function(template, CityData, CityDataI,storgeKey) {
    var storgeKey = storgeKey?storgeKey:'cityStore';
    var cityDialog = null;
    var list_iScroll_Chinese;
    var list_iScroll_International;
    var cityDialogContainer = [];


    // $(this).append(template);

    // $(this).find('#chinese .item-content').append(loadData(CityData));
    // $(this).find('#international .item-content').append(loadData(CityDataI));
    cityDialog = $(this).find("#cities");

    list_iScroll_Chinese = new iScroll($(this).find('#chinese .listSlider-content'));
    cityDialogContainer['chinese'] = $(this).find('#chinese').listSliderNavFullWindow("#chinese", {
        container: cityDialog
    }, list_iScroll_Chinese,storgeKey);


    list_iScroll_International = new iScroll($(this).find('#international .listSlider-content'));
    cityDialogContainer['international'] = $(this).find('#international').listSliderNavFullWindow("#international", {
        container: cityDialog,
        listSliderHeight: cityDialogContainer['chinese'].listSliderHeight
    }, list_iScroll_International,storgeKey);

    function loadData(datas) {
        var groups = datas.groups;
        var contentString = "";
        for (var i = 0; i < groups.length; i++) {
            contentString += ('<li id="' + groups[i].gruopName + '"><a name="' + groups[i].gruopName + '" class="title">' + groups[i].gruopName + '</a>');
            contentString += '</li>';
            for (var j = 0; j < groups[i].cities.length; j++) {
                contentString += ('<li><a class="cityName" data="' + groups[i].cities[j].cityName + '">' + groups[i].cities[j].cityName + '</a></li>');
            }
            //     contentString+='</ul>';
            // contentString+='</li>';
        }

        /*  original data struct
            for(var i=0;i<groups.length;i++){
                contentString+=('<li id="'+ groups[i].gruopName +'"><a name="'+ groups[i].gruopName +'" class="title">'+ groups[i].gruopName +'</a>');
                    contentString+='<ul>';
                    for(var j=0;j<groups[i].cities.length;j++){
                        contentString+=('<li><a class="cityName" data="'+ groups[i].cities[j].cityName +'">'+ groups[i].cities[j].cityName +'</a></li>');
                    }
                    contentString+='</ul>';
                contentString+='</li>';
            }
            */

        return contentString;
    }

    function navCityButtonClick(e) {
        var el = e.currentTarget;
        var width = $(el).width();
        var left = $(el).offset().left - $(el).parent().parent().offset().left;
        $(el).parent().find("td").removeClass("active");

        $(el).parent().parent().find('.scroll-slot .scroll-lite').css({
            left: left + 'px',
            width: width + 'px'
        });


        $(el).parent().find("td").removeClass("active");
        $(el).addClass("active");

        var id = $(el).attr('state');
        $('.cityBlock').hide();
        cityDialogContainer[id].show();

        if (id === 'chinese') {
            cityDialogContainer['chinese'].refreshHeight();
            setTimeout(function() {
                list_iScroll_Chinese.scrollTo(0, 1, 200, true);
            }, 10);
        } else {
            cityDialogContainer['international'].refreshHeight();
            setTimeout(function() {
                list_iScroll_International.scrollTo(0, 1, 200, true);
            }, 10);
        }


    }


    $(".navCityButton").live('click', navCityButtonClick);

    $("#cityFilter").on('input', function(e) {
        list_iScroll_Chinese.scrollTo(0, 0, 0, 0);
        list_iScroll_International.scrollTo(0, 0, 0, 0);
        var filterValue = $("#cityFilter").val();
        console.log(filterValue)
        if (filterValue.length === 0 || filterValue === '') {
            // $("#cityFilter").addClass('empty');
            $("#cities .listSlider-content").hide();
            $("#cities .cityName").show();
            $("#cities a.title").show();
            $("#cities .listSlider-content").show();

            setTimeout(function() {
                list_iScroll_Chinese.refresh();

                setTimeout(function() {
                    list_iScroll_International.refresh();
                }, 300);
            }, 300);

            return;
        } else {
            // $("#cityFilter").removeClass('empty');
        }

        filtByType("#chinese", filterValue);
        filtByType("#international", filterValue);

        setTimeout(function() {
            list_iScroll_Chinese.refresh();

            setTimeout(function() {
                list_iScroll_International.refresh();
            }, 300);
        }, 100);
        // body...
    })

    function filtByType(cityType, filterValue) {
        var cityItems =
            $("#cities " + cityType + " .cityName[data*='" + filterValue + "']");
        var itemSize = cityItems.length;
        $(cityType + " .cityName").hide();
        cityItems.show();

        $("#cities " + cityType + " a.title").hide();
        // $($("#cities a.title")[0]).show();
        var titleItems = $("#cities " + cityType + " a.title");
        for (var i = 0; i < itemSize; i++) {
            var cityIndex = $(cityItems[i]).parent().index();

            var markIndex = -1;
            for (var j = 0; j < titleItems.length; j++) {
                var titleIndex = $(titleItems[j]).parent().index();
                if ((cityIndex - titleIndex) > 0) {
                    markIndex = j;
                } else if (markIndex > -1) {
                    $(titleItems[markIndex]).show();
                    break;
                }
            }
            // $(cityItems[i]).parent().find('a.title').show();
        }
    }


    cityDialog.css("display","block");
    cityDialogContainer['chinese'].refreshHeight();

    $('.scroll-slot .scroll-lite').css({
            left: '0px',
            width: '50%'
        });
        cityDialogContainer['chinese'].show();


    setTimeout(function() {
        $($('.navCityButton')[0]).trigger('click');

        

    }, 50);

    var sliderObject = {
        show: function() {
            cityDialog.show();
        },

        hide: function() {
            cityDialog.hide();
        },

        setTarget: function(targetId, callBack) {
            cityDialog.css("display", "block");
            cityDialogContainer['chinese'].setTarget(targetId, callBack);
            cityDialogContainer['international'].setTarget(targetId, callBack);
            // cityDialogContainer['chinese'].show();
            setTimeout(function() {
                $($('.navCityButton')[0]).trigger('click');
            }, 300);
        },

        cityDialogContainer: cityDialogContainer
    };
    return sliderObject;
};