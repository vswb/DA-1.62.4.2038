(window.webpackJsonp=window.webpackJsonp||[]).push([[167],{1761:function(e,a,t){"use strict";t.r(a);var r=t(2234);for(var s in r)["default"].indexOf(s)<0&&function(e){t.d(a,e,(function(){return r[e]}))}(s);var n=t(0),o=t(3308),u=t.n(o),l=Object(n.a)(r.default,void 0,void 0,!1,null,null,null);"function"==typeof u.a&&u()(l),a.default=l.exports},1891:function(e,a,t){"use strict";t(16),t(14),t(23),t(25),t(18),t(6);var r=t(1),s=t(20);Object.defineProperty(a,"__esModule",{value:!0}),a.getLoginPMAStatus=a.globalLoginPMA=a.loginPMA=a.setUserPrivs=a.getUserPrivs=a.changeUserPassword=a.assignUser=a.addUser=a.deleteAccessHost=a.addAccessHost=a.deleteUsers=a.getDatabase=a.uploadBackup=a.deleteDatabase=a.optimizeDatabase=a.checkDatabase=a.repairDatabase=a.getDatabases=a.createDatabase=a.getUsers=void 0;var n=r(t(78)),o=function(e,a){if(!a&&e&&e.__esModule)return e;if(null===e||"object"!==s(e)&&"function"!=typeof e)return{default:e};var t=u(a);if(t&&t.has(e))return t.get(e);var r={},n=Object.defineProperty&&Object.getOwnPropertyDescriptor;for(var o in e)if("default"!==o&&Object.prototype.hasOwnProperty.call(e,o)){var l=n?Object.getOwnPropertyDescriptor(e,o):null;l&&(l.get||l.set)?Object.defineProperty(r,o,l):r[o]=e[o]}r.default=e,t&&t.set(e,r);return r}(t(9));function u(e){if("function"!=typeof WeakMap)return null;var a=new WeakMap,t=new WeakMap;return(u=function(e){return e?t:a})(e)}var l=n.default.get({id:"DB_USERS",url:"/CMD_DB_CREATE",domain:!0,mapResponse:{users:o.pipe(o.omit(["MAX_DB_LENGTH","MAX_DB_USER_LENGTH"]),o.values,o.filter((function(e){return"..."!==e.text})),o.map((function(e){return{value:e.value,label:e.text}}))),max_db_length:o.prop("MAX_DB_LENGTH"),max_db_user_length:o.prop("MAX_DB_USER_LENGTH")}});a.getUsers=l;var d=n.default.post({url:"/CMD_DB",params:{action:"create"},domain:!0,schema:{name:n.default.REQUIRED_STRING,user:n.default.REQUIRED_STRING,passwd:n.default.OPTIONAL_STRING,passwd2:n.default.OPTIONAL_STRING,userlist:n.default.OPTIONAL_STRING},after:function(e){return e.mapProp("result",e.convert.toAppHtml)},updateTokens:!0});a.createDatabase=d;var i=n.default.get({id:"DATABASES",url:"/CMD_DB",domain:!0,pagination:!0,after:function(e){return e.mapProps({databases:e.toTable(e.mapArrayProps({nusers:e.convert.toAppNumber,size:e.convert.toAppNumber})),HAVE_ONE_CLICK_PMA_LOGIN:e.convert.toAppBoolean,total_usage:e.convert.toAppNumber,dbs_select:e.toSelect})}});a.getDatabases=i;var p=n.default.select({url:"/CMD_DB",domain:!0,params:{json:!0}}),f=p.extend({params:{repair:!0}});a.repairDatabase=f;var c=p.extend({params:{check:!0}});a.checkDatabase=c;var _=p.extend({params:{optimize:!0}});a.optimizeDatabase=_;var R=p.extend({params:{delete_db:!0},updateTokens:!0});a.deleteDatabase=R;var m=n.default.post({url:"/CMD_DB",params:{action:"restore",method:"default"},domain:!0,schema:{name:n.default.REQUIRED_STRING,dbuser:n.default.REQUIRED_STRING,dbpass:n.default.REQUIRED_STRING,file:{type:File,required:!0}},before:function(e){return{file1:e.file,file:null}},transport:FormData,continous:!0});a.uploadBackup=m;var D=n.default.get({id:"DB_VIEW",url:"/CMD_DB_VIEW",params:{page:1,ipp:9999},domain:!0,schema:{name:n.default.REQUIRED_STRING},after:function(e){return e.flow(e.project({hosts:"access_hosts",users:"db_users",pmaLogin:"HAVE_ONE_CLICK_PMA_LOGIN"}),e.mapProps({users:e.flow(e.deleteProp("info"),e.toArray,e.mapArray(e.getProp("User"))),hosts:e.flow(e.deleteProp("info"),e.toArray,e.mapArray(e.getProp("Access Hosts"))),pmaLogin:e.convert.toAppBoolean}))}});a.getDatabase=D;var E=n.default.post({url:"/CMD_DB",method:"POST",params:{action:"deleteuser",delete:!0,json:!0},domain:!0,schema:{name:n.default.REQUIRED_STRING,select:n.default.ROWS}});a.deleteUsers=E;var I=n.default.post({url:"/CMD_DB_ACCESS",domain:!0,params:{add:!0,json:!0},schema:{name:n.default.REQUIRED_STRING,host:n.default.REQUIRED_STRING}});a.addAccessHost=I;var v=n.default.select({url:"/CMD_DB_ACCESS",domain:!0,params:{delete:!0,json:!0},schema:{name:n.default.REQUIRED_STRING}});a.deleteAccessHost=v;var S=n.default.post({url:"/CMD_DB",domain:!0,params:{action:"createuser",json:!0},schema:{name:n.default.REQUIRED_STRING,passwd:n.default.REQUIRED_STRING,passwd2:n.default.REQUIRED_STRING}});a.addUser=S;var b=n.default.post({url:"/CMD_DB",domain:!0,params:{action:"createuser",json:!0,passwd:"*****",passwd2:"*****"},schema:{name:n.default.REQUIRED_STRING,userlist:n.default.REQUIRED_STRING}});a.assignUser=b;var N=n.default.post({url:"/CMD_DB",domain:!0,params:{action:"modifyuser",json:!0},schema:{name:n.default.REQUIRED_STRING,user:n.default.REQUIRED_STRING,passwd:n.default.REQUIRED_STRING,passwd2:n.default.REQUIRED_STRING}});a.changeUserPassword=N;var A=n.default.get({id:"DB_USER_PRIVS",url:"/CMD_DB_USER_PRIVS",domain:!0,schema:{name:n.default.REQUIRED_STRING,user:n.default.REQUIRED_STRING},after:function(e){return e.mapValues(e.isEqual("Y"))}});a.getUserPrivs=A;var P=n.default.post({url:"/CMD_DB_USER_PRIVS",domain:!0,params:{action:"save "},body:{name:n.default.REQUIRED_STRING,user:n.default.REQUIRED_STRING}});a.setUserPrivs=P;var U=n.default.post({url:"/CMD_PMA_LOGIN",domain:!0,params:{json:!0},notifySuccess:!1,notifyError:!1,schema:{name:n.default.REQUIRED_STRING}});a.loginPMA=U;var g=n.default.post({url:"/CMD_PMA_LOGIN",params:{json:!0,name:"all",domain:""},notifySuccess:!1,notifyError:!1});a.globalLoginPMA=g;var M=n.default.get({url:"/CMD_DB",response:!1,mapResponse:function(e){return"yes"===e.HAVE_ONE_CLICK_PMA_LOGIN},notifyError:!1});a.getLoginPMAStatus=M},2234:function(e,a,t){"use strict";t.r(a);var r=t(2235),s=t.n(r);for(var n in r)["default"].indexOf(n)<0&&function(e){t.d(a,e,(function(){return r[e]}))}(n);a.default=s.a},2235:function(e,a,t){"use strict";var r=t(1);Object.defineProperty(a,"__esModule",{value:!0}),a.default=void 0;var s=r(t(36));t(24);var n,o=r(t(37)),u=t(1891),l=t(28),d=t(12),i={render:function(){return null},beforeRouteEnter:(n=(0,o.default)(s.default.mark((function e(a,t,r){var n,o,i,p,f,c;return s.default.wrap((function(e){for(;;)switch(e.prev=e.next){case 0:return n=(0,l.State)("app.tokens"),e.next=3,(0,u.getLoginPMAStatus)();case 3:if(o=e.sent,i=o instanceof Error,!o||i){e.next=14;break}return e.next=8,(0,u.globalLoginPMA)();case 8:if((p=e.sent)instanceof Error){e.next=14;break}return f=p.token,c=p.url,(0,d.openInNewTab)("".concat(c,"?token=").concat(f)),r(!1),e.abrupt("return");case 14:n.PHPMYADMIN_PUBLIC&&(0,d.openInNewTab)("".concat(n.WEBAPPS_SSL,"://").concat(n.HOSTNAME,"/phpmyadmin")),r(!1);case 16:case"end":return e.stop()}}),e)}))),function(e,a,t){return n.apply(this,arguments)})};a.default=i},3308:function(e,a){}}]);