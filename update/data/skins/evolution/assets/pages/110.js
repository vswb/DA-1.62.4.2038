(window.webpackJsonp=window.webpackJsonp||[]).push([[110],{1847:function(t,e,n){"use strict";n.r(e);var a=n(3955),r=n(2706);for(var o in r)["default"].indexOf(o)<0&&function(t){n.d(e,t,(function(){return r[t]}))}(o);var i=n(0),l=n(3705),s=n.n(l),c=Object(i.a)(r.default,a.a,a.b,!1,null,null,null);"function"==typeof s.a&&s()(c),e.default=c.exports},2706:function(t,e,n){"use strict";n.r(e);var a=n(2707),r=n.n(a);for(var o in a)["default"].indexOf(o)<0&&function(t){n.d(e,t,(function(){return a[t]}))}(o);e.default=r.a},2707:function(t,e,n){"use strict";n(7),n(10),n(5),n(6),n(8),n(11);var a=n(1);Object.defineProperty(e,"__esModule",{value:!0}),e.default=void 0;var r=a(n(36));n(27),n(26),n(34);var o=a(n(37)),i=a(n(2)),l=n(12),s=n(3115),c=a(n(3704));function u(t,e){var n=Object.keys(t);if(Object.getOwnPropertySymbols){var a=Object.getOwnPropertySymbols(t);e&&(a=a.filter((function(e){return Object.getOwnPropertyDescriptor(t,e).enumerable}))),n.push.apply(n,a)}return n}function p(t){for(var e=1;e<arguments.length;e++){var n=null!=arguments[e]?arguments[e]:{};e%2?u(Object(n),!0).forEach((function(e){(0,i.default)(t,e,n[e])})):Object.getOwnPropertyDescriptors?Object.defineProperties(t,Object.getOwnPropertyDescriptors(n)):u(Object(n)).forEach((function(e){Object.defineProperty(t,e,Object.getOwnPropertyDescriptor(n,e))}))}return t}var f,d,m={preload:s.getTemplates,api:s.getTemplates,components:{AddNewTemplate:c.default},data:function(){return{selectedRows:[]}},computed:p(p({templateNames:function(){return this.$api.templates.reduce((function(t,e){var n=e.template,a=e.name;return p(p({},t),{},(0,i.default)({},n,a))}))},locations:function(){var t=this;return this.$api.locations.map((function(e){return p(p({},e),{},{template:t.templateNames[e.nginx_template]})}))}},(0,l.mapTokens)({nginxProxy:"HAVE_NGINX_PROXY"})),{},{settings:function(){return this.$api.settings},isDisabled:function(){return!0===this.nginxProxy&&"1"===this.settings.nginx_proxy&&"0"===this.settings.domain_nginx}}),methods:{addTemplateDialog:function(){this.$dialog("ADD_TEMPLATE_DIALOG").open()},deleteTemplates:(d=(0,o.default)(r.default.mark((function t(){return r.default.wrap((function(t){for(;;)switch(t.prev=t.next){case 0:return t.next=2,(0,s.deleteTemplates)({select:this.selectedRows.map((function(t){return t.location}))});case 2:(0,s.getTemplates)(),this.selectedRows=[];case 4:case"end":return t.stop()}}),t,this)}))),function(){return d.apply(this,arguments)}),toggleNginxState:(f=(0,o.default)(r.default.mark((function t(){return r.default.wrap((function(t){for(;;)switch(t.prev=t.next){case 0:return t.next=2,(0,s.toggleNginxState)({state:this.isDisabled});case 2:(0,s.getTemplates)();case 3:case"end":return t.stop()}}),t,this)}))),function(){return f.apply(this,arguments)})}};e.default=m},2708:function(t,e,n){"use strict";n.r(e);var a=n(2709),r=n.n(a);for(var o in a)["default"].indexOf(o)<0&&function(t){n.d(e,t,(function(){return a[t]}))}(o);e.default=r.a},2709:function(t,e,n){"use strict";n(7),n(10),n(5),n(6),n(8),n(11);var a=n(1);Object.defineProperty(e,"__esModule",{value:!0}),e.default=void 0;var r=a(n(36)),o=a(n(37)),i=a(n(2));n(27),n(26);var l=n(3115);function s(t,e){var n=Object.keys(t);if(Object.getOwnPropertySymbols){var a=Object.getOwnPropertySymbols(t);e&&(a=a.filter((function(e){return Object.getOwnPropertyDescriptor(t,e).enumerable}))),n.push.apply(n,a)}return n}var c,u={api:l.getTemplates,data:function(){return{location:"/",template:""}},computed:{templates:function(){return this.$api.templates.reduce((function(t,e){return function(t){for(var e=1;e<arguments.length;e++){var n=null!=arguments[e]?arguments[e]:{};e%2?s(Object(n),!0).forEach((function(e){(0,i.default)(t,e,n[e])})):Object.getOwnPropertyDescriptors?Object.defineProperties(t,Object.getOwnPropertyDescriptors(n)):s(Object(n)).forEach((function(e){Object.defineProperty(t,e,Object.getOwnPropertyDescriptor(n,e))}))}return t}((0,i.default)({},e.template,e.name),t)}),{})}},watch:{location:function(t,e){var n=this;""===t&&e&&this.$nextTick((function(){n.location=e}))}},methods:{addTemplate:(c=(0,o.default)(r.default.mark((function t(){return r.default.wrap((function(t){for(;;)switch(t.prev=t.next){case 0:return t.next=2,(0,l.addTemplate)({location:this.location,nginx_template:this.template});case 2:if(!(t.sent instanceof Error)){t.next=5;break}return t.abrupt("return");case 5:(0,l.getTemplates)();case 6:case"end":return t.stop()}}),t,this)}))),function(){return c.apply(this,arguments)})}};e.default=u},3115:function(t,e,n){"use strict";n(7),n(10),n(5),n(6),n(8),n(11),n(16),n(14),n(23),n(25),n(18);var a=n(1),r=n(20);Object.defineProperty(e,"__esModule",{value:!0}),e.toggleNginxState=e.deleteTemplates=e.addTemplate=e.getTemplates=void 0;var o=a(n(2)),i=a(n(38)),l=a(n(78)),s=function(t,e){if(!e&&t&&t.__esModule)return t;if(null===t||"object"!==r(t)&&"function"!=typeof t)return{default:t};var n=c(e);if(n&&n.has(t))return n.get(t);var a={},o=Object.defineProperty&&Object.getOwnPropertyDescriptor;for(var i in t)if("default"!==i&&Object.prototype.hasOwnProperty.call(t,i)){var l=o?Object.getOwnPropertyDescriptor(t,i):null;l&&(l.get||l.set)?Object.defineProperty(a,i,l):a[i]=t[i]}a.default=t,n&&n.set(t,a);return a}(n(9));function c(t){if("function"!=typeof WeakMap)return null;var e=new WeakMap,n=new WeakMap;return(c=function(t){return t?n:e})(t)}function u(t,e){var n=Object.keys(t);if(Object.getOwnPropertySymbols){var a=Object.getOwnPropertySymbols(t);e&&(a=a.filter((function(e){return Object.getOwnPropertyDescriptor(t,e).enumerable}))),n.push.apply(n,a)}return n}function p(t){for(var e=1;e<arguments.length;e++){var n=null!=arguments[e]?arguments[e]:{};e%2?u(Object(n),!0).forEach((function(e){(0,o.default)(t,e,n[e])})):Object.getOwnPropertyDescriptors?Object.defineProperties(t,Object.getOwnPropertyDescriptors(n)):u(Object(n)).forEach((function(e){Object.defineProperty(t,e,Object.getOwnPropertyDescriptor(n,e))}))}return t}var f=s.curry((function(t,e){return s.map((function(e){var n=(0,i.default)(e,2),a=n[0];return p(p({},n[1]),{},(0,o.default)({},t,a))}),s.toPairs(e))})),d=l.default.get({url:"/CMD_NGINX_TEMPLATES",id:"NGINX_TEMPLATES",domain:!0,mapResponse:{locations:s.pipe(s.prop("locations"),f("location")),templates:s.pipe(s.prop("templates"),f("template")),settings:s.prop("settings")}});e.getTemplates=d;var m=l.default.post({url:"/CMD_NGINX_TEMPLATES",domain:!0,params:{action:"save"},schema:{location:l.default.REQUIRED_STRING,nginx_template:l.default.REQUIRED_STRING}});e.addTemplate=m;var b=l.default.select({url:"/CMD_NGINX_TEMPLATES",domain:!0,params:{action:"delete"}});e.deleteTemplates=b;var g=l.default.post({url:"/CMD_DOMAIN",domain:!0,params:{action:"modify",only_affect:"nginx"},schema:{state:l.default.REQUIRED_BOOL},before:function(t){return{state:null,nginx:t.state?"1":"0"}}});e.toggleNginxState=g},3704:function(t,e,n){"use strict";n.r(e);var a=n(4095),r=n(2708);for(var o in r)["default"].indexOf(o)<0&&function(t){n.d(e,t,(function(){return r[t]}))}(o);var i=n(0),l=Object(i.a)(r.default,a.a,a.b,!1,null,null,null);e.default=l.exports},3705:function(t,e){},3955:function(t,e,n){"use strict";n.d(e,"a",(function(){return a})),n.d(e,"b",(function(){return r}));var a=function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("app-page",{attrs:{actions:[{label:t.$gettext("Add Template"),icon:"#plus-fill",handler:t.addTemplateDialog,visible:!1===t.isDisabled},{label:t.isDisabled?t.$gettext("Enable"):t.$gettext("Disable"),icon:"#console",handler:t.toggleNginxState}]}},[!1===t.isDisabled?n("ui-button",{key:"add-template-button",attrs:{slot:"header:buttons",theme:"safe"},on:{click:t.addTemplateDialog},slot:"header:buttons"},[n("translate",[t._v("Add Template")])],1):t._e(),t._v(" "),n("ui-button",{key:"toggle-button",attrs:{slot:"header:buttons",theme:t.isDisabled?"safe":"danger"},on:{click:t.toggleNginxState},slot:"header:buttons"},[t._v("\n        "+t._s(t.isDisabled?t.$gettext("Enable"):t.$gettext("Disable"))+"\n    ")]),t._v(" "),n("app-page-section",[n("ui-r-table",{attrs:{rows:t.locations,columns:[{id:"location",label:t.$gettext("Location")},{id:"template",label:t.$gettext("Template")}],"checked-rows":t.selectedRows},on:{"update:checkedRows":function(e){t.selectedRows=e},"update:checked-rows":function(e){t.selectedRows=e}}},[n("ui-table-action",{attrs:{slot:"table:actions"},on:{click:t.deleteTemplates},slot:"table:actions"},[n("translate",[t._v("Delete")])],1)],1)],1),t._v(" "),n("add-new-template")],1)},r=[]},4095:function(t,e,n){"use strict";n.d(e,"a",(function(){return a})),n.d(e,"b",(function(){return r}));var a=function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("ui-dialog",{attrs:{id:"ADD_TEMPLATE_DIALOG",size:"normal"}},[n("translate",{attrs:{slot:"title"},slot:"title"},[t._v("\n        Add Template\n    ")]),t._v(" "),n("template",{slot:"content"},[n("ui-form-element",{attrs:{vertical:"",group:"add-nginx-template",validators:{required:!0}}},[n("translate",{attrs:{slot:"title"},slot:"title"},[t._v("\n                Location\n            ")]),t._v(" "),n("input-text",{attrs:{slot:"content"},slot:"content",model:{value:t.location,callback:function(e){t.location=e},expression:"location"}})],1),t._v(" "),n("ui-form-element",{attrs:{vertical:""}},[n("translate",{attrs:{slot:"title"},slot:"title"},[t._v("\n                Template\n            ")]),t._v(" "),n("input-select",{attrs:{slot:"content",options:t.templates},slot:"content",model:{value:t.template,callback:function(e){t.template=e},expression:"template"}})],1)],1),t._v(" "),n("ui-button",{attrs:{slot:"buttons",theme:"safe","validate-group":"add-nginx-template",disabled:!t.template},on:{click:t.addTemplate},slot:"buttons"},[n("translate",[t._v("Add Template")])],1)],2)},r=[]}}]);