define(["backbone","jqueryui","d3","nv","biPartite","Handlebars","QuickBase","css!./css/app.css"],function(o,e,i,n,s,a,r){"use strict";var l,d=this&&this.__extends||(l=function(e,t){return(l=Object.setPrototypeOf||{__proto__:[]}instanceof Array&&function(e,t){e.__proto__=t}||function(e,t){for(var i in t)Object.prototype.hasOwnProperty.call(t,i)&&(e[i]=t[i])})(e,t)},function(e,t){if("function"!=typeof t&&null!==t)throw new TypeError("Class extends value "+String(t)+" is not a constructor or null");function i(){this.constructor=e}l(e,t),e.prototype=null===t?Object.create(t):(i.prototype=t.prototype,new i)}),c=function(e,t,i){for(var n,o,s=0,a=e.length-1;s<=a;)if(0<(n=i(t,e[o=a+s>>1])))s=1+o;else{if(!(n<0))return o;a=o-1}return-s-1},p=function(e,t){return e.i>t.i?1:e.i<t.i?-1:e.n>t.n?1:e.n<t.n?-1:0},h=(u.app=a.template({compiler:[8,">= 4.3.0"],main:function(e,t,i,n,o){return'<div class="controls">\n    <div class="toggleArea">\n      \n        <label class="toogleSwitch">\n            <input class="toogleSwitch-input" type="checkbox" checked="true" />\n            <span class="toogleSwitch-label" data-true-value="Event" data-false-value="Time"></span> \n            <span class="toogleSwitch-handle"></span> \n        </label>\n        <select class="speed-Control">\n          \n        </select>\n    </div>\n    <div class="startBtn multi">Start</div>\n    <div class="rewindBtn multi">Rewind</div>\n    <div class="reverseBackBtn multi">reverse</div>\n    <div class="playBackBtn">Play</div>\n    <div class="fastforwardBtn multi">Forward</div>\n    <div class="endBtn multi">End</div>\n</div>\n<input class="slider" type="range" min="0" value="0" step="1" />\n'},useData:!0}),u);function u(){}m.getComponentDefinition=function(e){var t={id:47,componentName:"Play",componentDescription:"This element displays Bar Charts.",appKey:"PlayBack",data:e.websiteUrl+"/schema/PlayBack.json",listViewThumb:e.websiteUrl+"Images/PlayBack.png",ghostViewThumb:null,buildViewThumb:null,appArgs:{quickStart:[{path:"Basics.Data"}],json:{version:"4.4.0",possiblePeriod:[""],Basics:{Data:"",Selected:"",SelectedColumn:"",TimeColumn:"",Mode:"Event",Speed:"1x",Playing:0,MaxOverallTime:60,IntervalTime:1,multiStateControl:!1,speedControl:!1,ForcePause:!1,DisplayWarning:!1},Alignment:{paddingLeft:"0",paddingRight:"0",paddingTop:"0",paddingBottom:"0"},Style:{advanced:""},format:{}},schema:{type:"object",propertyOrder:1,title:"Properties",properties:{possiblePeriod:{type:"array",format:"table",items:{type:"string"},default:[],options:{collapsed:!0,hidden:!0}},Basics:{type:"object",propertyOrder:2,title:"Basics",options:{collapsed:!1},properties:{Data:{type:"data",format:"string",propertyOrder:1,title:"Data Source",default:""},Selected:{type:"viewstate",propertyOrder:2,title:"Selected Value",default:""},SelectedColumn:{type:"string",title:"Selected Column",propertyOrder:3,enumSource:"possible_selected_columns",watch:{possible_selected_columns:"root.possiblePeriod"}},TimeColumn:{type:"string",title:"Time Column",propertyOrder:4,enumSource:"possible_selected_columns",watch:{possible_selected_columns:"root.possiblePeriod"}},Mode:{title:"Mode",type:"string",enum:["Event","Time"],propertyOrder:5,default:"Event"},speedControl:{type:"boolean",title:"Speed Controls",propertyOrder:6,format:"checkbox"},multiStateControl:{type:"boolean",title:"Multi Controls",propertyOrder:7,format:"checkbox"},MaxOverallTime:{type:"number",title:"Max Overall Time",propertyOrder:8,format:"number"},IntervalTime:{type:"number",title:"Interval Time",propertyOrder:9,format:"number"},Speed:{propertyOrder:10,type:"string",enum:["1x","2x","4x","8x","16x"],default:"1x"},Playing:{type:"number",title:"Playing",propertyOrder:11,format:"number"},ForcePause:{type:"boolean",title:"Force Pause",propertyOrder:12,format:"checkbox",options:{hidden:!0}},DisplayWarning:{type:"boolean",title:"Display Warning Message",propertyOrder:13,format:"checkbox"}}},Alignment:{type:"object",propertyOrder:3,title:"Margins",options:{collapsed:!0},properties:{paddingLeft:{type:"number",title:"Padding Left",default:0,format:"number"},paddingRight:{type:"number",title:"Padding Right",default:0,format:"number"},paddingTop:{type:"number",title:"Padding Top",default:0,format:"number"},paddingBottom:{type:"number",title:"Padding Bottom",default:0,format:"number"}}},Style:{type:"object",title:"Style",options:{collapsed:!0},properties:{advanced:{type:"css",title:"Advanced CSS",default:""}}}},format:{type:"object",title:"Format",options:{collapsed:!0},properties:{}}}}};if(0<_.keys(e.settingsModel.attributes).length)for(var i=_.find(m.upgrades,{version:e.settingsModel.get("version")}),n=void 0===i?1:m.upgrades.indexOf(i)+1;n<m.upgrades.length;n+=1){var o=m.upgrades[n];o.fn(e.settingsModel),e.settingsModel.set("version",o.version)}return t},m.upgrades=[{version:"4.0.0",fn:function(e){var t=e.get("Basics");void 0!==t.DisplayWarning&&t.DisplayWarning,e.set("Basics",t)}},{version:"4.2.0",fn:function(e){var t=e.get("Basics");t.Speed="number"==typeof t.Speed?"1x":t.Speed,e.set("Basics",t)}},{version:"4.4.0",fn:function(e){var t=e.get("Basics");t.Playing=t.Playing||0,e.set("Basics",t)}}];a=m;function m(){}var g,f=r.Tools;function y(e){var t=g.call(this,e)||this;return t.dataModel=null,t.direction=0,t.lastSelectedIndex=0,t.lastTime=0,t.running=!1,t.speed=1,t.themeClass="",t.subscriptionKey=_.uniqueId("PlayBacks_"),t.api=e.api,t.viewModel=new o.DeepModel,t.primaryKey="_rowIndex",t.dashModel=e.dashboardViewModel,t.collection=new o.Collection([],{model:o.Model.extend({idAttribute:t.primaryKey})}),t.columnInfo=new o.Collection([],{model:o.Model.extend({idAttribute:"id"})}),t.columnInfo.comparator="index",t.hideErrorMessage=e.api.hideErrorMessage,t.showErrorMessage=e.api.showErrorMessage,t.el.className+=" PlayBack",t.$el.html(h.app()),t.$slider=t.$el.find(".slider"),t.$multiControl=t.$el.find(".multi"),t.$toggleArea=t.$el.find(".toggleArea"),t.$speedControl=t.$el.find(".speed-Control"),t.$toggleSwitch=t.$el.find(".toogleSwitch"),t.$btnStart=t.$el.find(".startBtn").button({text:!1,icons:{primary:"fa fa-fast-backward"}}),t.$btnRewind=t.$el.find(".rewindBtn").button({text:!1,icons:{primary:"fa fa-backward"}}),t.$btnFastFwd=t.$el.find(".fastforwardBtn").button({text:!1,icons:{primary:"fa fa-forward"}}),t.$btnEnd=t.$el.find(".endBtn").button({text:!1,icons:{primary:"fa fa-fast-forward"}}),t.$btnPlay=t.$el.find(".playBackBtn").button({text:!1,icons:{primary:"fa fa-play"}}),t.$btnPlayRev=t.$el.find(".reverseBackBtn").button({text:!1,icons:{primary:"fa fa-play fa-rotate-180"}}),t.initializeEvents(),t.onPropThemeChange(),t}return g=o.View,d(y,g),y.prototype.onSettingsChange=function(e){var i=this;_.each(e,function(e,t){i.viewModel.set(t,e)})},y.prototype.remove=function(){return this.dataModel&&(this.dataModel.unsubscribe(this.subscriptionKey),this.dataModel=null),o.View.prototype.remove.apply(this)},y.prototype.initializeEvents=function(){var e=this;this.listenTo(this.viewModel,"change:Basics.Data",this.onPropDataChange.bind(this)),this.listenTo(this.viewModel,"change:Basics.Selected",this.onPropSelectedChange.bind(this)),this.listenTo(this.viewModel,"change:Basics.SelectedColumn",this.onPropSelectedColumnChange.bind(this)),this.listenTo(this.viewModel,"change:Basics.TimeColumn",this.onPropTimeColumnChange.bind(this)),this.listenTo(this.viewModel,"change:Basics.speedControl",this.onPropSpeedControlChange.bind(this)),this.listenTo(this.viewModel,"change:Basics.Speed",this.onPropSelectedSpeed.bind(this)),this.listenTo(this.viewModel,"change:Basics.Mode",this.onPropModeChange.bind(this)),this.listenTo(this.viewModel,"change:Basics.multiStateControl",this.onPropMultiStateControlChange.bind(this)),this.listenTo(this.dashModel,"change:DashboardTheme",this.onPropThemeChange.bind(this)),this.$btnPlay.on("click",this.onBtnPlayClick.bind(this)),this.$btnPlayRev.on("click",this.onBtnRevClick.bind(this)),this.$btnStart.on("click",this.onBtnStartClick.bind(this)),this.$btnRewind.on("click",this.onBtnRewindClick.bind(this)),this.$btnFastFwd.on("click",this.onBtnFastFwdClick.bind(this)),this.$btnEnd.on("click",this.onBtnEndClick.bind(this)),this.$slider.off("change").on("change",function(){e.setSelectedIndex(e.$slider.val())})},y.prototype.getSpeedFloat=function(){return Number((this.viewModel.get("Basics.Speed")||1).replace("x",""))},y.prototype.getSpeedDropdownSettings=function(){var e,t=this,i=this.viewModel.get("Basics.Speed"),n="Event"===this.viewModel.get("Basics.Mode")?[{id:1,text:"1x"},{id:2,text:"2x"},{id:4,text:"4x"},{id:8,text:"8x"},{id:16,text:"16x"}]:[{id:.25,text:"0.25x"},{id:.5,text:"0.5x"},{id:1,text:"1x"},{id:2,text:"2x"},{id:4,text:"4x"},{id:8,text:"8x"}];return i&&!_.find(n,{text:i})&&(e=this.getSpeedFloat(),n.push({id:e,text:i}),this.$speedControl.removeClass("select2-offscreen").select2({theme:"dashboards",data:n,minimumResultsForSearch:-1}).off("select2:select").on("select2:select",function(){t.speed=Number(t.$speedControl.val())}).trigger("select2:select"),this.$speedControl.val(i).trigger("change"),this.speed=e),n},y.prototype.onBtnEndClick=function(){this.running=!1,this.updatePlaying(),this.setSelectedIndex(this.collection.models.length-1),this.resetButtons()},y.prototype.onBtnFastFwdClick=function(){this.running=!1,this.updatePlaying(),this.setSelectedIndex(Math.min(this.collection.models.length-1,this.lastSelectedIndex+1)),this.resetButtons()},y.prototype.onBtnPlayClick=function(){this.running=!this.running,!0===this.running?(this.$btnPlay.button({label:"pause",icons:{primary:"fa fa-pause"}}),this.direction=1,this.lastTime=(new Date).getTime(),this.stepFn()):this.$btnPlay.button({label:"play",icons:{primary:"fa fa-play"}}),this.updatePlaying(),this.$btnPlayRev.button({icons:{primary:"fa fa-play fa-rotate-180"}})},y.prototype.onBtnRevClick=function(){this.running=!this.running,!0===this.running?(this.$btnPlayRev.button({label:"pause",icons:{primary:"fa fa-pause"}}),this.direction=-1,this.lastTime=(new Date).getTime(),this.stepFn()):this.$btnPlayRev.button({label:"play",icons:{primary:"fa fa-play fa-rotate-180"}}),this.updatePlaying(),this.$btnPlay.button({icons:{primary:"fa fa-play"}})},y.prototype.onBtnRewindClick=function(){this.running=!1,this.updatePlaying(),this.setSelectedIndex(Math.max(0,this.lastSelectedIndex-1)),this.resetButtons()},y.prototype.onBtnStartClick=function(){this.running=!1,this.updatePlaying(),this.setSelectedIndex(0),this.resetButtons()},y.prototype.onData=function(t,e){var i=!1,n=t.columns;t.primaryKey!==this.primaryKey&&(this.primaryKey=t.primaryKey,this.collection.reset(),this.collection=new o.Collection([],{model:o.Model.extend({idAttribute:this.primaryKey})}),i=!0),n.reset?this.columnInfo.reset(t.columns.reset):(this.columnInfo.remove(_.map(n.remove,function(e){return e[t.primaryKey]})),this.columnInfo.add(n.add),this.columnInfo.add(n.change,{merge:!0})),(i=i||_.some(["add","remove","reset","change"],function(e){return void 0!==n[e]}))&&(this.columnInfo.sort(),this.api.setProperty("possiblePeriod",this.columnInfo.pluck("id"))),e.reset?this.collection.reset(e.reset):(this.collection.remove(_.map(e.remove,function(e){return e[t.primaryKey]})),this.collection.add(e.add),this.collection.add(e.change,{merge:!0})),this.lastSelectedIndex=0,this.updateIndex()},y.prototype.onPropDataChange=function(e,i){var n=this,o=!!this.viewModel.get("Basics.DisplayWarning");this.dataModel&&(this.stopListening(this.dataModel),this.api.unsubscribe(this.dataModel)),!i&&o?this.showErrorMessage({error:t("To populate this component, please define a")+" <b> "+t("Data Source")+"</b> "+t("from")+"<b> "+t("Properties")+"-"+t("Basics")+"</b>",type:"Warning"},this.dataModel):(this.hideErrorMessage(),this.dataModel=i,this.dataModel&&this.dataModel.attributes||!o?(this.api.subscribe(this.dataModel,this.onData.bind(this)),this.listenTo(this.dataModel,"change:error",function(){n.updateErrorMessage()})):this.showErrorMessage({error:t("Invalid Data Source")+': "'+i.path+'" '+t("selected"),type:"Warning"},this.dataModel))},y.prototype.onPropModeChange=function(e,t){var i=this,n="Event"===t;this.$toggleSwitch.find("input").prop("checked",n),this.$toggleSwitch.find("input").off().click(function(){_.delay(function(){i.api.setProperty("Basics.Mode",n?"Time":"Event")},400)}),this.renderSpeedDropDown()},y.prototype.onPropMultiStateControlChange=function(e,t){t?this.$multiControl.show():this.$multiControl.hide()},y.prototype.onPropSelectedChange=function(){var e,t,i,n=this.viewModel.get("Basics.SelectedColumn"),o=this.viewModel.get("Basics.Selected");null!=o&&null!=(i=_.isNumber(o)?o:f.convertISODatetimeToKDBLikeObject(o))&&this.collection.models&&this.collection.models[this.lastSelectedIndex]&&(t=void 0,12<=(t=this.columnInfo.get(n)?this.columnInfo.get(n).get("kdbType"):t)&&t<=19?(i=f.convertValueToMoment(o,"12"+t).toKdbObject(),e=c(this.collection.models,i,function(e,t){return t=t.get(n),p(e,t)}),this.setSelectedIndex(e,!0)):i!==this.collection.models[this.lastSelectedIndex]&&(e=c(this.collection.models,7===t?Number(i):i,function(e,t){return(t=t.get(n))<e?1:e<t?-1:0}),this.setSelectedIndex(e,!0)))},y.prototype.onPropSelectedColumnChange=function(){this.updateIndex()},y.prototype.onPropSelectedSpeed=function(){var e=this.getSpeedDropdownSettings(),t=this.viewModel.get("Basics.Speed"),i=t&&t.match(/^((\d*\.)?\d+)x$/),i=(i&&i[1]&&(this.speed=Number(i[1])),_.filter(e,function(e){return e.text===t})),e=i[0]&&i[0].id?i[0].id:1;this.$speedControl.val(e).trigger("change"),this.updatePlaying()},y.prototype.onPropSpeedControlChange=function(){var e=this;this.viewModel.get("Basics.speedControl")?(this.$toggleArea.show(),this.$speedControl.show(),this.$slider.off("change").on("change",function(){e.setSelectedIndex(e.$slider.val())})):this.$toggleArea.hide()},y.prototype.onPropThemeChange=function(){var e=this.viewModel.get("Basics.Theme")?this.viewModel.get("Basics.Theme").toLowerCase():"Dark";this.dashModel.get("DashboardTheme")&&(e=this.dashModel.get("DashboardTheme").toLowerCase()),this.themeClass!==e&&(this.$el.removeClass(this.themeClass),this.themeClass=e,this.$el.addClass(this.themeClass))},y.prototype.onPropTimeColumnChange=function(e,t){t||this.api.setProperty("Basics.Mode","Event"),this.$toggleSwitch.prop("disabled",!t)},y.prototype.renderSpeedDropDown=function(){var i=this;this.$speedControl.empty(),this.$speedControl.removeClass("select2-offscreen").select2({theme:"dashboards",data:this.getSpeedDropdownSettings(),minimumResultsForSearch:-1}).off("select2:select").val(this.speed).on("select2:select",function(){var e=i.getSpeedDropdownSettings(),t=Number(i.$speedControl.val()),e=_.find(e,{id:t});i.speed=t,i.api.setProperty("Basics.Speed",null==e?void 0:e.text)}).trigger("select2:select"),this.$speedControl.off("select2:open").on("select2:open",function(){$("body > .select2-container--dashboards.select2-container--open").addClass("select2--document")}),this.onPropSelectedSpeed()},y.prototype.resetButtons=function(){this.$btnPlay.button({icons:{primary:"fa fa-play"}}),this.$btnPlayRev.button({icons:{primary:"fa fa-play fa-rotate-180"}})},y.prototype.setSelectedIndex=function(e,t){var i=this.viewModel.get("Basics.SelectedColumn");e=Math.max(0,e),e=Math.min(e,this.collection.models.length-1),this.$slider.val(e),void 0!==this.collection.models[e]&&(this.lastSelectedIndex=e,t||(t=this.collection.models[e].get(i),this.api.setProperty("Basics.Selected",f.isKDBTemporal(t)?f.convertKDBTemporalToMoment(t).toDashString():t)))},y.prototype.stepFn=function(){var e,t,i=(new Date).getTime(),n=i-this.lastTime,o=this.speed/this.viewModel.get("Basics.IntervalTime"),s=this.viewModel.get("Basics.TimeColumn");this.running&&(!this.dataModel||this.dataModel.isDirty||this.dataModel.isPending?this.lastTime=i:"Time"===this.viewModel.get("Basics.Mode")?(e=this.collection.models[this.lastSelectedIndex].get(s).i+this.direction*n*o,(t=(t=c(this.collection.models,e,function(e,t){return e>t.get(s).i?1:e<t.get(s).i?-1:0}))<0?-t+(1===this.direction?-2:-1):t)!==this.lastSelectedIndex&&(this.setSelectedIndex(t),1===this.direction&&(i+=this.collection.models[this.lastSelectedIndex].get(s).i-e,console.log("Offset",this.collection.models[this.lastSelectedIndex].get(s).i-e)),this.lastTime=i)):1e3/o<=n&&(this.lastTime=i,t=Math.round(n/(1e3/o)),this.setSelectedIndex(this.lastSelectedIndex+this.direction*t)),window.requestAnimationFrame(this.stepFn.bind(this)))},y.prototype.updateErrorMessage=function(){var e,t=!!this.viewModel.get("Basics.DisplayWarning");null!=(e=this.dataModel)&&e.get("error")&&t?this.showErrorMessage(this.dataModel.get("error")):this.hideErrorMessage()},y.prototype.updateIndex=function(){this.$slider.attr("max",this.collection.models.length-1),this.onPropSelectedChange()},y.prototype.updatePlaying=function(){this.api.setProperty("Basics.Playing",this.running?this.direction*this.getSpeedFloat():0)},y.getComponentDefinition=a.getComponentDefinition,y});