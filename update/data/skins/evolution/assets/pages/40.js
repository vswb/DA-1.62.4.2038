(window.webpackJsonp=window.webpackJsonp||[]).push([[40],{1713:function(t,e,n){"use strict";n.r(e);var a=n(3824),s=n(2043);for(var r in s)["default"].indexOf(r)<0&&function(t){n.d(e,t,(function(){return s[t]}))}(r);var i=n(0),o=n(3147),l=n.n(o),u=Object(i.a)(s.default,a.a,a.b,!1,null,null,null);"function"==typeof l.a&&l()(u),e.default=u.exports},2043:function(t,e,n){"use strict";n.r(e);var a=n(2044),s=n.n(a);for(var r in a)["default"].indexOf(r)<0&&function(t){n.d(e,t,(function(){return a[t]}))}(r);e.default=s.a},2044:function(t,e,n){"use strict";var a=n(1);Object.defineProperty(e,"__esModule",{value:!0}),e.default=void 0;var s,r=a(n(36)),i=a(n(37)),o=n(1931),l=n(58),u=a(n(3142)),c=a(n(3143)),d=a(n(3144)),f=a(n(3145)),p={preload:[o.getCrons,o.getCurrentBackups],api:[{command:o.getCrons,bind:"crons"},{command:o.getCurrentBackups,bind:"currentBackups"}],commands:{getCrons:o.getCrons},components:{CronsTable:u.default,CurrentBackupsTable:c.default,BackupRestoreSettingsDialog:d.default,MonitorBackupStatusDialog:f.default},mixins:[(0,l.$bindTab)({defaultTab:"scheduled",param:"tab"})],data:function(){return{select:[],refreshTimeout:3e4,refresh:!0,viewDialogPid:void 0}},computed:{currentBackups:function(){return this.$api.currentBackups},crons:function(){return this.$api.crons},haveBackupsRunning:function(){return!!this.currentBackups.rowsCount},hasResellerBackups:function(){return this.$api.crons.has_reseller_level_backups}},watch:{haveBackupsRunning:function(t,e){!t&&e&&(this.tab="scheduled")}},mounted:function(){var t=this;this.refreshCurrentBackups(),"in-progress"!==this.tab||this.haveBackupsRunning||this.$nextTick((function(){t.tab="scheduled"}))},beforeDestroy:function(){clearTimeout(this.timeoutId)},methods:{refreshCurrentBackups:(s=(0,i.default)(r.default.mark((function t(){return r.default.wrap((function(t){for(;;)switch(t.prev=t.next){case 0:if(!this.refresh){t.next=3;break}return t.next=3,(0,o.getCurrentBackups)();case 3:this.timeoutId=setTimeout(this.refreshCurrentBackups,this.refreshTimeout);case 4:case"end":return t.stop()}}),t,this)}))),function(){return s.apply(this,arguments)}),showDetails:function(t){var e=this;this.viewDialogPid=t,this.$nextTick((function(){return e.$dialog("MONITOR_BACKUP_STATUS_DIALOG").open()}))}}};e.default=p},2045:function(t,e,n){"use strict";n.r(e);var a=n(2046),s=n.n(a);for(var r in a)["default"].indexOf(r)<0&&function(t){n.d(e,t,(function(){return a[t]}))}(r);e.default=s.a},2046:function(t,e,n){"use strict";Object.defineProperty(e,"__esModule",{value:!0}),e.default=void 0,n(34);var a=n(1931),s={data:function(){return{select:[]}},commands:{getCrons:a.getCrons},methods:{duplicateCrons:function(){(0,a.duplicateCrons)({select:this.select}).then(this.$reloadApiTable)},deleteCrons:function(){(0,a.deleteCrons)({select:this.select}).then(this.$reloadApiTable)},runBackups:function(){(0,a.runCrons)({select:this.select}).then(this.$reloadApiTable)},getDataLabels:function(t){var e={domain:this.$gettext("Domain Directory"),subdomain:this.$gettext("Subdomain Lists"),ftp:this.$gettext("FTP Accounts"),ftpsettings:this.$gettext("FTP Settings"),database:this.$gettext("Database Settings"),database_data:this.$gettext("Database Data"),forwarder:this.$gettext("Forwarders"),email:this.$gettext("E-mail Accounts"),email_data:this.$gettext("E-mail Data"),emailsettings:this.$gettext("E-mail Settings"),vacation:this.$gettext("Vacation Messages"),autoresponder:this.$gettext("Autoresponders"),list:this.$gettext("Mailing Lists"),trash:this.$gettext("Deleted Trash Data")};return t.map((function(t){return e[t]}))}}};e.default=s},2047:function(t,e,n){"use strict";n.r(e);var a=n(2048),s=n.n(a);for(var r in a)["default"].indexOf(r)<0&&function(t){n.d(e,t,(function(){return a[t]}))}(r);e.default=s.a},2048:function(t,e,n){"use strict";var a=n(1);Object.defineProperty(e,"__esModule",{value:!0}),e.default=void 0,n(55),n(34);var s,r=a(n(36)),i=a(n(37)),o=n(1931),l={commands:{getCurrentBackups:o.getCurrentBackups},data:function(){return{select:[]}},methods:{killBackup:(s=(0,i.default)(r.default.mark((function t(){return r.default.wrap((function(t){for(;;)switch(t.prev=t.next){case 0:return t.next=2,(0,o.killBackup)({select:this.select});case 2:t.sent&&(this.$reset(),(0,o.getCurrentBackups)());case 4:case"end":return t.stop()}}),t,this)}))),function(){return s.apply(this,arguments)}),getDataLabels:function(t){var e={domain:this.$gettext("Domain Directory"),subdomain:this.$gettext("Subdomain Lists"),ftp:this.$gettext("FTP Accounts"),ftpsettings:this.$gettext("FTP Settings"),database:this.$gettext("Database Settings"),database_data:this.$gettext("Database Data"),forwarder:this.$gettext("Forwarders"),email:this.$gettext("E-mail Accounts"),email_data:this.$gettext("E-mail Data"),emailsettings:this.$gettext("E-mail Settings"),vacation:this.$gettext("Vacation Messages"),autoresponder:this.$gettext("Autoresponders"),list:this.$gettext("Mailing Lists")};return t.map((function(t){return e[t]})).join(", ")},showDetails:function(t){this.select=[],this.$emit("showDetails",t)}}};e.default=l},2049:function(t,e,n){"use strict";n.r(e);var a=n(2050),s=n.n(a);for(var r in a)["default"].indexOf(r)<0&&function(t){n.d(e,t,(function(){return a[t]}))}(r);e.default=s.a},2050:function(t,e,n){"use strict";n(7),n(10),n(5),n(6),n(8),n(11),n(16),n(14),n(23),n(25),n(18);var a=n(1),s=n(20);Object.defineProperty(e,"__esModule",{value:!0}),e.default=void 0;var r=a(n(36));n(49);var i=a(n(37)),o=a(n(2)),l=function(t,e){if(!e&&t&&t.__esModule)return t;if(null===t||"object"!==s(t)&&"function"!=typeof t)return{default:t};var n=c(e);if(n&&n.has(t))return n.get(t);var a={},r=Object.defineProperty&&Object.getOwnPropertyDescriptor;for(var i in t)if("default"!==i&&Object.prototype.hasOwnProperty.call(t,i)){var o=r?Object.getOwnPropertyDescriptor(t,i):null;o&&(o.get||o.set)?Object.defineProperty(a,i,o):a[i]=t[i]}a.default=t,n&&n.set(t,a);return a}(n(9)),u=n(1931);function c(t){if("function"!=typeof WeakMap)return null;var e=new WeakMap,n=new WeakMap;return(c=function(t){return t?n:e})(t)}function d(t,e){var n=Object.keys(t);if(Object.getOwnPropertySymbols){var a=Object.getOwnPropertySymbols(t);e&&(a=a.filter((function(e){return Object.getOwnPropertyDescriptor(t,e).enumerable}))),n.push.apply(n,a)}return n}function f(t){for(var e=1;e<arguments.length;e++){var n=null!=arguments[e]?arguments[e]:{};e%2?d(Object(n),!0).forEach((function(e){(0,o.default)(t,e,n[e])})):Object.getOwnPropertyDescriptors?Object.defineProperties(t,Object.getOwnPropertyDescriptors(n)):d(Object(n)).forEach((function(e){Object.defineProperty(t,e,Object.getOwnPropertyDescriptor(n,e))}))}return t}var p,v={api:[{command:u.getBackupSettings,bind:"settings"}],data:function(){return{message:!0,local_ns:!1,restore_spf:!0,confirm_with_domainowners:!0,show:!1,directadmin_conf:[]}},computed:{hasDaSettings:function(){return!!this.$api.settings.directadmin_conf},options:function(){return["backup_ftp_pre_test","backup_ftp_md5","allow_backup_encryption","restore_database_as_admin","tally_after_restore","backup_hard_link_check","webmail_backup_is_email_data"]},daValuesEncoded:function(){var t=this;return this.hasDaSettings?l.reduce((function(e,n){return f(f({},e),{},(0,o.default)({},n,l.contains(n,t.directadmin_conf)?"1":"0"))}),{},this.options):[]},requestData:function(){return f({message:this.message,local_ns:this.local_ns,restore_spf:this.restore_spf,confirm_with_domainowners:this.confirm_with_domainowners},this.daValuesEncoded)}},created:function(){this.optionLinks={backup_ftp_pre_test:"https://www.directadmin.com/features.php?id=1386",backup_ftp_md5:"https://www.directadmin.com/features.php?id=1977",allow_backup_encryption:"https://www.directadmin.com/features.php?id=2117",restore_database_as_admin:"https://www.directadmin.com/features.php?id=1817",tally_after_restore:"https://www.directadmin.com/features.php?id=853",backup_hard_link_check:"https://www.directadmin.com/features.php?id=1061",webmail_backup_is_email_data:"https://www.directadmin.com/features.php?id=2292"}},methods:{loadSettings:(p=(0,i.default)(r.default.mark((function t(){var e;return r.default.wrap((function(t){for(;;)switch(t.prev=t.next){case 0:return this.show=!1,t.next=3,(0,u.getBackupSettings)();case 3:e=t.sent,Object.assign(this,e),this.directadmin_conf=l.keys(l.filter(l.equals(!0),this.$api.settings.directadmin_conf)),this.show=!0;case 7:case"end":return t.stop()}}),t,this)}))),function(){return p.apply(this,arguments)}),saveSettings:function(){(0,u.updateSettings)(this.requestData)}}};e.default=v},2051:function(t,e,n){"use strict";n.r(e);var a=n(2052),s=n.n(a);for(var r in a)["default"].indexOf(r)<0&&function(t){n.d(e,t,(function(){return a[t]}))}(r);e.default=s.a},2052:function(t,e,n){"use strict";var a=n(1);Object.defineProperty(e,"__esModule",{value:!0}),e.default=void 0;var s=a(n(36)),r=a(n(37));n(24);var i,o=n(1931),l=new(a(n(3146)).default),u={props:{id:{type:String,required:!1,default:""}},data:function(){return{showFilesize:!1,status:""}},api:[{command:o.getCurrentBackup,bind:{response:"backup",isOk:"backupLoaded"}}],computed:{overview:function(){return l.state.overview},percent:function(){return l.state.percent},details:function(){return l.state.details},requestURL:function(){var t=this.id,e=Math.random();return"/CMD_ADMIN_BACKUP?action=monitor&get=tracking_data&pid=".concat(t,"&rand=").concat(e,"&type=sse")},filesize:function(){return l.state.filesize}},watch:{filesize:function(){this.showFilesize||(this.showFilesize=!0)},details:function(){this.showFilesize=!1}},methods:{connect:(i=(0,r.default)(s.default.mark((function t(){return s.default.wrap((function(t){for(;;)switch(t.prev=t.next){case 0:return this.status="",t.next=3,(0,o.getCurrentBackup)({pid:this.id});case 3:return t.prev=3,this.status=this.$gettext("Reading from tracker stream..."),t.next=7,l.open(this.requestURL);case 7:this.status=this.$gettext("Tracker stream was closed!"),t.next=13;break;case 10:t.prev=10,t.t0=t.catch(3),this.status=this.$gettext("Error getting backup details");case 13:case"end":return t.stop()}}),t,this,[[3,10]])}))),function(){return i.apply(this,arguments)}),updateCurrentBackups:o.getCurrentBackups}};e.default=u},3142:function(t,e,n){"use strict";n.r(e);var a=n(3983),s=n(2045);for(var r in s)["default"].indexOf(r)<0&&function(t){n.d(e,t,(function(){return s[t]}))}(r);var i=n(0),o=Object(i.a)(s.default,a.a,a.b,!1,null,null,null);e.default=o.exports},3143:function(t,e,n){"use strict";n.r(e);var a=n(3984),s=n(2047);for(var r in s)["default"].indexOf(r)<0&&function(t){n.d(e,t,(function(){return s[t]}))}(r);var i=n(0),o=Object(i.a)(s.default,a.a,a.b,!1,null,null,null);e.default=o.exports},3144:function(t,e,n){"use strict";n.r(e);var a=n(3985),s=n(2049);for(var r in s)["default"].indexOf(r)<0&&function(t){n.d(e,t,(function(){return s[t]}))}(r);var i=n(0),o=Object(i.a)(s.default,a.a,a.b,!1,null,null,null);e.default=o.exports},3145:function(t,e,n){"use strict";n.r(e);var a=n(3986),s=n(2051);for(var r in s)["default"].indexOf(r)<0&&function(t){n.d(e,t,(function(){return s[t]}))}(r);var i=n(0),o=Object(i.a)(s.default,a.a,a.b,!1,null,null,null);e.default=o.exports},3146:function(t,e,n){"use strict";var a=n(1);Object.defineProperty(e,"__esModule",{value:!0}),e.default=void 0,n(17),n(14),n(73),n(49);var s=a(n(102)),r=a(n(103)),i=a(n(30)),o=n(135),l=function(t){return(new DOMParser).parseFromString((0,o.toAppString)(t),"text/html").body.textContent||""},u=function(){function t(){(0,s.default)(this,t),this.state=i.default.observable({overview:"",details:"",percent:0,filesize:0})}return(0,r.default)(t,[{key:"setOverview",value:function(t){this.state.overview=l(t)}},{key:"setDetails",value:function(t){this.state.details=l(t)}},{key:"setPercent",value:function(t){this.state.percent=Number(t)||0}},{key:"setFilesize",value:function(t){this.state.filesize=Number(t)||0}},{key:"open",value:function(t){var e=this;return new Promise((function(n,a){var s=new EventSource(t);s.addEventListener("open",(function(){return Object.assign(e.state,{overview:"",details:"",percent:0,filesize:0,reconnects:0})}),!1),s.addEventListener("message",(function(t){try{var a=JSON.parse(t.data);"1"===a.finished&&(s.close(),n(t)),a.dynamic_text&&e.setOverview(a.dynamic_text),a.dynamic_details&&e.setDetails(a.dynamic_details),a.percent&&e.setPercent(a.percent),a.filesize&&e.setFilesize(a.filesize)}catch(t){}}),!1),s.addEventListener("error",(function(t){t.readyState===EventSource.CLOSED?n(t):a(t)}),!1)}))}}]),t}();e.default=u},3147:function(t,e){},3824:function(t,e,n){"use strict";n.d(e,"a",(function(){return a})),n.d(e,"b",(function(){return s}));var a=function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("app-page",{attrs:{actions:[{name:"admin/backups/schedule",label:t.$gettext("Schedule"),icon:"#plus-fill"},{name:"admin/backups/restore",label:t.$gettext("Restore"),icon:"#extract"}]}},[n("template",{slot:"header:buttons"},[n("ui-button-link",{attrs:{theme:"safe",name:"admin/backups/schedule"}},[n("translate",[t._v("Schedule")])],1),t._v(" "),n("ui-button-link",{attrs:{theme:"primary",name:"admin/backups/restore"}},[n("translate",[t._v("Restore")])],1)],1),t._v(" "),n("app-page-section",[n("ui-tabs",{attrs:{tabs:[{id:"scheduled",label:t.$gettext("Scheduled Backups")},t.haveBackupsRunning?{id:"in-progress",label:t.$gettext("In Progress")}:{}],selected:t.tab,"hide-single-tab":""},on:{"update:selected":function(e){t.tab=e}}},[n("crons-table",{attrs:{slot:"tab:scheduled"},slot:"tab:scheduled"}),t._v(" "),n("current-backups-table",{attrs:{slot:"tab:in-progress"},on:{showDetails:t.showDetails},slot:"tab:in-progress"})],1)],1),t._v(" "),n("backup-restore-settings-dialog"),t._v(" "),n("monitor-backup-status-dialog",t._b({},"monitor-backup-status-dialog",{id:t.viewDialogPid},!1)),t._v(" "),n("ui-link",{attrs:{slot:"bottom:links",bullet:"",name:"user/backup"},slot:"bottom:links"},[n("translate",[t._v("Site Backup")])],1),t._v(" "),t.hasResellerBackups?n("ui-link",{attrs:{slot:"bottom:links",bullet:"",name:"reseller/backups"},slot:"bottom:links"},[n("translate",[t._v("Switch to Reseller Level Backups")])],1):t._e(),t._v(" "),n("ui-link",{attrs:{slot:"bottom:links",bullet:""},on:{click:function(e){t.$dialog("BACKUP_RESTORE_SETTINGS").open()}},slot:"bottom:links"},[n("translate",[t._v("Backup/Restore Settings")])],1)],2)},s=[]},3983:function(t,e,n){"use strict";n.d(e,"a",(function(){return a})),n.d(e,"b",(function(){return s}));var a=function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("app-page-section",[n("ui-api-table",t._b({attrs:{"disable-pagination":""},on:{"action:duplicate":t.duplicateCrons,"action:run":t.runBackups,"action:del":function(e){t.$dialog("DELETE_ITEMS_DIALOG").open()}},scopedSlots:t._u([{key:"col:when",fn:function(e){var a=e.when;return[n("div",{directives:[{name:"flex",rawName:"v-flex",value:{dir:"column"},expression:"{ dir: 'column' }"}]},[n("translate",{attrs:{"translate-params":a}},[t._v("\n                    Minute: %{minute}\n                ")]),t._v(" "),n("translate",{attrs:{"translate-params":a}},[t._v("\n                    Hour: %{hour}\n                ")]),t._v(" "),n("translate",{attrs:{"translate-params":a}},[t._v("\n                    Day of Month: %{dayofmonth}\n                ")]),t._v(" "),n("translate",{attrs:{"translate-params":a}},[t._v("\n                    Month: %{month}\n                ")]),t._v(" "),n("translate",{attrs:{"translate-params":a}},[t._v("\n                    Day of Week: %{dayofweek}\n                ")])],1)]}},{key:"col:who",fn:function(e){var a=e.who;return["all"===a.who?n("translate",[t._v("\n                All Users\n            ")]):"selected"===a.who?[n("translate",{attrs:{tag:"strong"}},[t._v("\n                    Selected Users:\n                ")]),t._v(" "),t._l(a.select,(function(e){return n("li",{key:e},[t._v("\n                    "+t._s(e)+"\n                ")])}))]:[n("translate",{attrs:{tag:"strong"}},[t._v("\n                    All Users Except:\n                ")]),t._v(" "),t._l(a.select,(function(e){return n("li",{key:e},[t._v("\n                    "+t._s(e)+"\n                ")])}))],t._v(" "),"yes"===a.skip_suspended?n("ui-tooltip",{attrs:{theme:"danger",icon:"warning"}},[n("translate",[t._v("Skip Suspended")])],1):t._e()]}},{key:"col:what",fn:function(e){var a=e.what;return["all"===a.what?n("translate",[t._v("\n                All Data\n            ")]):t._l(t.getDataLabels(a.select),(function(e){return n("li",{key:e},[t._v("\n                    "+t._s(e)+"\n                ")])}))]}},{key:"col:where",fn:function(e){var a=e.where,s=a.encrypted,r=a.path;return[s?n("ui-tooltip",{attrs:{theme:"safe",icon:"locked-padlock"}},[n("translate",[t._v("Encrypted")])],1):t._e(),t._v("\n            "+t._s(r)+"\n        ")]}},{key:"row:actions",fn:function(e){var a=e.id;return n("ui-button-link",{attrs:{name:"admin/backups/modify",params:{id:a},icon:"pencil",title:t.$gettext("Modify")}})}}]),model:{value:t.select,callback:function(e){t.select=e},expression:"select"}},"ui-api-table",{command:t.$commands.getCrons,rowID:"id",columns:{when:{label:t.$gettext("When"),grow:!0,width:"150px"},who:{label:t.$gettext("Who"),width:"150px"},where:{label:t.$gettext("Where"),width:"250px",grow:!0},what:t.$gettext("What")},actions:{run:t.$gettext("Run Now"),duplicate:t.$gettext("Duplicate"),del:t.$gettext("Delete")},verticalLayout:t.$_Client.isPhone},!1)),t._v(" "),n("ui-dialog-delete-items",{attrs:{subject:t.$ngettext("scheduled backup","scheduled backups",t.select.length)},on:{"click:confirm":t.deleteCrons}})],1)},s=[]},3984:function(t,e,n){"use strict";n.d(e,"a",(function(){return a})),n.d(e,"b",(function(){return s}));var a=function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("ui-api-table",t._b({on:{"action:kill":t.killBackup},scopedSlots:t._u([{key:"col:start",fn:function(e){var a=e.start;return[n("div",{directives:[{name:"flex",rawName:"v-flex",value:{dir:"column"},expression:"{ dir: 'column' }"}]},[n("translate",{attrs:{"translate-params":a}},[t._v("Minute: %{minute}")]),t._v(" "),n("translate",{attrs:{"translate-params":a}},[t._v("Hour: %{hour}")]),t._v(" "),n("translate",{attrs:{"translate-params":a}},[t._v("Day of Month: %{dayofmonth}")]),t._v(" "),n("translate",{attrs:{"translate-params":a}},[t._v("Month: %{month}")]),t._v(" "),n("translate",{attrs:{"translate-params":a}},[t._v("Day of Week: %{dayofweek}")])],1)]}},{key:"col:who",fn:function(e){var a=e.who;return["all"===a.who?n("translate",[t._v("All Users")]):"selected"===a.who?[n("translate",{attrs:{tag:"strong"}},[t._v("Selected Users:")]),t._v(" "),t._l(a.select,(function(e){return n("li",[t._v(t._s(e))])}))]:[n("translate",{attrs:{tag:"strong"}},[t._v("All Users Except:")]),t._v(" "),t._l(a.select,(function(e){return n("li",[t._v(t._s(e))])}))],t._v(" "),"yes"===a.skip_suspended?n("ui-tooltip",{attrs:{theme:"danger",icon:"warning"}},[n("translate",[t._v("Skip Suspended")])],1):t._e()]}},{key:"col:type",fn:function(e){var n=e.type;return[t._v("\n        "+t._s("restore"===n?t.$gettext("Restore"):t.$gettext("Backup"))+"\n    ")]}},{key:"col:what",fn:function(e){var a=e.what;return["all"===a.what?n("translate",[t._v("\n            All Data\n        ")]):[t._v("\n            "+t._s(t.getDataLabels(a.select))+"\n        ")]]}},{key:"col:where",fn:function(e){var a=e.where;return[a.encrypted?n("ui-tooltip",{attrs:{theme:"safe",icon:"locked-padlock"}},[n("translate",[t._v("Encrypted")])],1):t._e(),t._v("\n            "+t._s(a.path)+"\n    ")]}},{key:"col:progress",fn:function(e){var a=e.progress;return n("ui-progress",{attrs:{theme:"safe",size:"big",value:a}},[t._v("\n        "+t._s(a)+"%\n    ")])}},{key:"row:actions",fn:function(e){var a=e.pid;return n("ui-button",{attrs:{theme:"light",size:"small"},on:{click:function(e){return t.showDetails(a)}}},[n("translate",[t._v("Details")])],1)}}]),model:{value:t.select,callback:function(e){t.select=e},expression:"select"}},"ui-api-table",{command:t.$commands.getCurrentBackups,rowID:"pid",columns:{pid:t.$gettext("PID"),id:t.$gettext("Backup ID"),type:t.$gettext("Type"),start:t.$gettext("Start Time"),who:t.$gettext("Who"),where:t.$gettext("Where"),progress:t.$gettext("Progress")},actions:{kill:t.$gettext("Kill")},updateOn:[],verticalLayout:t.$_Client.isPhone},!1))},s=[]},3985:function(t,e,n){"use strict";n.d(e,"a",(function(){return a})),n.d(e,"b",(function(){return s}));var a=function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("ui-dialog",{attrs:{id:"BACKUP_RESTORE_SETTINGS"},on:{"dialog:open":t.loadSettings}},[n("translate",{attrs:{slot:"title"},slot:"title"},[t._v("\n        Backup/Restore Settings\n    ")]),t._v(" "),n("template",{directives:[{name:"show",rawName:"v-show",value:t.show,expression:"show"}],slot:"content"},[n("ui-form-element",[n("input-checkbox",{attrs:{slot:"content"},slot:"content",model:{value:t.message,callback:function(e){t.message=e},expression:"message"}},[n("translate",[t._v("Send a message when a backup has finished.")])],1)],1),t._v(" "),n("ui-form-element",[n("div",{directives:[{name:"flex",rawName:"v-flex",value:{dir:"column"},expression:"{ dir:'column' }"}],attrs:{slot:"content"},slot:"content"},[n("input-radio",{attrs:{value:!0},model:{value:t.local_ns,callback:function(e){t.local_ns=e},expression:"local_ns"}},[n("translate",[t._v("\n                        Restore with local NameServers.\n                    ")])],1),t._v(" "),n("input-radio",{attrs:{value:!1},model:{value:t.local_ns,callback:function(e){t.local_ns=e},expression:"local_ns"}},[n("translate",[t._v("\n                        Use NS values from backup.\n                    ")])],1)],1)]),t._v(" "),n("ui-form-element",[n("div",{directives:[{name:"flex",rawName:"v-flex",value:{dir:"column"},expression:"{ dir:'column' }"}],attrs:{slot:"content"},slot:"content"},[n("input-radio",{attrs:{value:!0},model:{value:t.restore_spf,callback:function(e){t.restore_spf=e},expression:"restore_spf"}},[n("translate",[t._v("\n                        Restore with SPF values from backup.\n                    ")])],1),t._v(" "),n("input-radio",{attrs:{value:!1},model:{value:t.restore_spf,callback:function(e){t.restore_spf=e},expression:"restore_spf"}},[n("translate",[t._v("\n                        Use local SPF values.\n                    ")])],1)],1)]),t._v(" "),n("ui-form-element",[n("input-checkbox",{attrs:{slot:"content"},slot:"content",model:{value:t.confirm_with_domainowners,callback:function(e){t.confirm_with_domainowners=e},expression:"confirm_with_domainowners"}},[n("translate",[t._v("On restore, check for domain conflict in domainowners file, rather than the named.conf, or remote named.conf files.")])],1)],1),t._v(" "),n("ui-form-element",{attrs:{vertical:""}},[n("translate",{attrs:{slot:"title"},slot:"title"},[t._v("\n                directadmin.conf values\n            ")]),t._v(" "),n("input-select-multiple",{attrs:{slot:"content","hide-header":"",options:t.options},slot:"content",model:{value:t.directadmin_conf,callback:function(e){t.directadmin_conf=e},expression:"directadmin_conf"}},t._l(t.options,(function(e){return n("span",{directives:[{name:"flex",rawName:"v-flex",value:{dir:"row",cross:"center",main:"between"},expression:"{\n                        dir: 'row',\n                        cross: 'center',\n                        main: 'between',\n                    }"}],key:e,attrs:{slot:"option:"+e},slot:"option:"+e},[n("span",{domProps:{innerHTML:t._s(e)}}),t._v(" "),n("ui-link",{attrs:{href:t.optionLinks[e],target:"_blank"},nativeOn:{click:function(t){t.stopPropagation()}}},[n("ui-icon",{attrs:{id:"question",theme:"neutral",size:"medium"}})],1)],1)})),0)],1)],1),t._v(" "),n("ui-button",{attrs:{slot:"buttons",theme:"safe"},on:{click:t.saveSettings},slot:"buttons"},[n("translate",[t._v("Save")])],1)],2)},s=[]},3986:function(t,e,n){"use strict";n.d(e,"a",(function(){return a})),n.d(e,"b",(function(){return s}));var a=function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("ui-dialog",{attrs:{noCloseBtn:"",id:"MONITOR_BACKUP_STATUS_DIALOG",size:"normal"},on:{"dialog:open":t.connect,"dialog:close":t.updateCurrentBackups}},[n("translate",{attrs:{slot:"title","translate-params":{id:t.id}},slot:"title"},[t._v("\n        Monitor Backup: %{ id }\n    ")]),t._v(" "),n("template",{slot:"content"},[t.$api.backupLoaded?n("ui-table",{attrs:{vertical:t.$_Client.isPhone,items:[t.$api.backup]}},[n("ui-column",{attrs:{id:"id",label:t.$gettext("Backup ID"),fit:""}}),t._v(" "),n("ui-column",{attrs:{id:"owner",label:t.$gettext("Owner")}}),t._v(" "),n("ui-column",{attrs:{id:"start",label:t.$gettext("Start Time")},scopedSlots:t._u([{key:"default",fn:function(e){return[t._v("\n                    "+t._s(t._f("date")(e.start))+"\n                ")]}}],null,!1,942224404)}),t._v(" "),n("ui-column",{attrs:{id:"who",label:t.$gettext("Who")},scopedSlots:t._u([{key:"default",fn:function(e){return["all"===e.who.who?n("translate",[t._v("All Users")]):"selected"===e.who.who?[n("translate",{attrs:{tag:"strong"}},[t._v("Selected Users:")]),t._v(" "),t._l(e.who.select,(function(e){return n("li",[t._v(t._s(e))])}))]:[n("translate",{attrs:{tag:"strong"}},[t._v("All Users Except:")]),t._v(" "),t._l(e.who.select,(function(e){return n("li",[t._v(t._s(e))])}))],t._v(" "),"yes"===e.who.skip_suspended?n("ui-tooltip",{attrs:{theme:"danger",icon:"warning"}},[n("translate",[t._v("Skip Suspended")])],1):t._e()]}}],null,!1,2944117371)}),t._v(" "),n("ui-column",{attrs:{id:"where",label:t.$gettext("Where")}})],1):t._e(),t._v(" "),t.percent?n("ui-progress",{attrs:{value:t.percent,size:"big",theme:"primary"}},[t._v("\n            "+t._s(t.percent)+" %\n        ")]):t._e(),t._v(" "),t.overview?n("ui-form-element",[n("translate",{attrs:{slot:"title"},slot:"title"},[t._v("Overview:")]),t._v(" "),n("span",{attrs:{slot:"content"},slot:"content"},[t._v("\n                "+t._s(t.overview)+"\n            ")])],1):t._e(),t._v(" "),t.details&&t.percent<100?n("ui-form-element",[n("translate",{attrs:{slot:"title"},slot:"title"},[t._v("Details:")]),t._v(" "),n("span",{attrs:{slot:"content"},slot:"content"},[t._v("\n                "+t._s(t.details)+"\n                "),t.showFilesize?[t._v("\n                    - "+t._s(t._f("humanReadableSize")(t.filesize))+"\n                ")]:t._e()],2)],1):t._e(),t._v(" "),t.status?n("ui-form-element",{attrs:{vertical:""}},[n("span",{attrs:{slot:"content"},domProps:{textContent:t._s(t.status)},slot:"content"})]):t._e()],1)],2)},s=[]}}]);