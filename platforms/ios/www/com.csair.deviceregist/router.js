define(['zepto', 'cube/router', 'com.csair.deviceregist/register'],
	function($, CubeRouter, Regist){

	var Router = CubeRouter.extend({

		module: 'com.csair.deviceregist',

		routes: {
			'': 'showRegist',
		},

		showRegist: function(){
			this.changePage(new Regist());
		},

	});

	return Router;
});