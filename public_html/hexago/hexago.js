function putborder(l,map,col){
	if (typeof(col)==='undefined') col = '';
	if (l==1){
		//map[[0,0]]=col;
	} else {
		var dirs=[[0,1],[1,0],[1,-1],[0,-1],[-1,0],[-1,1]];
		var loc=[-l+1,0];
		for (var i = 0; i < 6; i++) { 
			for (var j = 0; j < l-1; j++) { 
				map[loc]=col;
				loc[0]+=dirs[i][0];
				loc[1]+=dirs[i][1];
			}
		}
	}
	return map;
}
function putboard(l,map){
	for (var k=1;k<=l;k++){
		putborder(k,map);
	}
	return map;
}


// For canvas

function Grid(canvasId, l) {
	this.map={};
	putboard(l,this.map);
	this.canvas = document.getElementById(canvasId);
	this.context = this.canvas.getContext('2d');

	var rect = this.canvas.getBoundingClientRect();
	var paddingY=(document.documentElement || document.body.parentNode || document.body).scrollTop;
	this.canvasOriginX = rect.left;
	this.canvasOriginY = rect.top+paddingY;

	this.d=this.canvas.width/(2*l+1);
	this.l=l;
	this.yvec=[this.d/2,this.d*Math.sin(Math.PI/3)];

	this.x0=this.canvas.width/2;
	this.y0=this.canvas.height/2;
	this.sl=(this.l-1)*this.d;
	this.h=Math.sin(Math.PI/3)*this.d;
	this.ssl=Math.sin(Math.PI/3)*this.sl;
	this.csl=Math.cos(Math.PI/3)*this.sl;	
	
	this.canvas.addEventListener("mousedown", this.clickEvent.bind(this), false);
}
Grid.prototype.updateParams = function(){
	var rect = this.canvas.getBoundingClientRect();
	var paddingY=(document.documentElement || document.body.parentNode || document.body).scrollTop;
	this.canvasOriginX = rect.left;
	this.canvasOriginY = rect.top+paddingY;

	this.d=this.canvas.width/(2*l+1);
	this.l=l;
	this.yvec=[this.d/2,this.d*Math.sin(Math.PI/3)];

	this.x0=this.canvas.width/2;
	this.y0=this.canvas.height/2;
	this.sl=(this.l-1)*this.d;
	this.h=Math.sin(Math.PI/3)*this.d;
	this.ssl=Math.sin(Math.PI/3)*this.sl;
	this.csl=Math.cos(Math.PI/3)*this.sl;
}
Grid.prototype.drawLine = function(x0, y0, x1, y1, col, text) {
	if (typeof(col)==='undefined') col = "#000";
	if (typeof(text)==='undefined') text = "";
	this.context.strokeStyle = col;
	this.context.beginPath();
	this.context.moveTo(x0, y0);
	this.context.lineTo(x1, y1);
	this.context.stroke();

	if (text) {
		this.context.font = "8px";
		this.context.fillStyle = "#000";
		this.context.fillText(text, x0 - this.d / 3, y0-this.d/30);
	}
};
Grid.prototype.drawGridLine=function(offset,lineWidth,ax,col,text,clearfirst){
	if (typeof(lineWidth)==='undefined') lineWidth = 1;
	if (typeof(ax)==='undefined') ax = 'x';
	if (typeof(col)==='undefined') col = "#000";
	if (typeof(text)==='undefined') text = "";
	if (typeof(clearfirst)==='undefined') clearfirst = false;
	if (clearfirst){
		this.drawGrid();
	}
	this.context.lineWidth=lineWidth;
	this.context.strokeStyle = col;
	var sl=(this.l-1)*this.d;
	var h=Math.sin(Math.PI/3)*this.d;
	var ssl=Math.sin(Math.PI/3)*sl;
	var csl=Math.cos(Math.PI/3)*sl;
	if (ax=='x'){
		this.drawLine(this.x0-sl+Math.abs(offset)*this.d/2,this.y0-offset*h,this.x0+sl-Math.abs(offset)*this.d/2,this.y0-offset*h,col,text);
	} else if (ax=='y') {
		offset=-offset;
		if (offset>0) {
			this.drawLine(this.x0-csl-offset*this.d/2,this.y0+ssl-offset*h,this.x0+csl-offset*this.d,this.y0-ssl,col,text);
		} else {
			this.drawLine(this.x0-csl-offset*this.d,this.y0+ssl,this.x0+csl-offset*this.d/2,this.y0-ssl-offset*h,col,text);
		}
	} else {
		this.drawLine(this.x0+csl+offset*this.d/2,this.y0+ssl-offset*h,this.x0-csl+offset*this.d,this.y0-ssl);
	}
};
Grid.prototype.drawGrid = function() {
	this.context.clearRect(0, 0, this.canvas.width, this.canvas.height);
	this.context.strokeStyle='#000';
	this.context.lineWidth=1;
	this.drawLine(this.x0-this.sl,this.y0,this.x0+this.sl,this.y0);
	this.drawLine(this.x0-this.csl,this.y0+this.ssl,this.x0+this.csl,this.y0-this.ssl);
	this.drawLine(this.x0+this.csl,this.y0+this.ssl,this.x0-this.csl,this.y0-this.ssl);
	for (var i = 1; i < this.l; i++) {
		//this.drawGridLine(i);
		//this.drawGridLine(-i);
		this.drawGridLine(i,1,"x");
		this.drawGridLine(-i,1,"x");
		this.drawGridLine(i,1,"y");
		this.drawGridLine(-i,1,"y");
		//this.drawLine(this.x0-this.sl+i*this.d/2,this.y0-i*this.h,this.x0+this.sl-i*this.d/2,this.y0-i*this.h);
		//this.drawLine(this.x0-this.csl-i*this.d/2,this.y0+this.ssl-i*this.h,this.x0+this.csl-i*this.d,this.y0-this.ssl);
		//this.drawLine(this.x0-this.csl+i*this.d,this.y0+this.ssl,this.x0+this.csl+i*this.d/2,this.y0-this.ssl+i*this.h);
		this.drawLine(this.x0+this.csl+i*this.d/2,this.y0+this.ssl-i*this.h,this.x0-this.csl+i*this.d,this.y0-this.ssl);
		this.drawLine(this.x0+this.csl-i*this.d,this.y0+this.ssl,this.x0-this.csl-i*this.d/2,this.y0-this.ssl+i*this.h);
	}
	this.drawCircleKey("0,0","#909");
	for (var key in this.map){
		if (this.map[key]){
			this.drawCircleKey(key,this.map[key]);
		}
	}
	var o=document.getElementById('x').value;
	this.drawGridLine(o,3,'x',"#909",o);
	o=document.getElementById('y').value;
	this.drawGridLine(o,3,'y',"#909",o);

	var s=this.score();
	var ss="";
	var w=this.canvas.width;
	for (var i=0;i<s[0].length;i++){
		i==0?0:ss+=", ";
		this.drawCircle(w/15,w/15+i*w/15,s[1][i],w/15*s[0][i]/s[0][0]);
		ss+=s[1][i]+": "+s[0][i];
	}
	document.getElementById("scores").value=ss;
};
Grid.prototype.drawCircle=function(x,y,col,r){
	if (typeof(r)==='undefined') r = this.d/2;
	//this.context.strokeStyle='#000';//document.getElementById("col").value;
	this.context.fillStyle=col;//document.getElementById("col").value;
	this.context.beginPath();
	this.context.arc(x,y,r,0,2*Math.PI);
	//this.context.stroke();
	this.context.fill();

};
Grid.prototype.drawCircleKey=function(key,col){
	var xy=key.split(',');
	//console.log(xy)
	this.drawCircleAt(parseInt(xy[0],10),parseInt(xy[1],10),col);
};
Grid.prototype.drawCircleAt=function(xi,yi,col){
	var x=this.x0+xi*this.d+yi*this.yvec[0];
	var y=this.y0-yi*this.yvec[1];
	//console.log(x,y)
	this.drawCircle(x,y,col);
};
function distance(x1,y1,x2,y2){
	return Math.sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2));
}
Grid.prototype.clickEvent = function (e) {
	var mouseX = e.pageX;
	var mouseY = e.pageY;
	var localX = mouseX - this.canvasOriginX;
	var localY = mouseY - this.canvasOriginY;
	for (var key in this.map){
		var xy=key.split(',');
		var x=this.x0+parseInt(xy[0],10)*this.d+parseInt(xy[1],10)*this.yvec[0];
		var y=this.y0-parseInt(xy[1],10)*this.yvec[1];
		if (distance(localX,localY,x,y)<this.d/2){
			//console.log(key);
			document.getElementById("x").value=xy[1];
			document.getElementById("y").value=xy[0];
			document.getElementById("x").onchange();
			this.drawCircle(x,y,document.getElementById("col").value);
			break;
		}
	}
};
function keytoloc(key){
	var xy=key.split(',');
	return [parseInt(xy[0],10),parseInt(xy[1],10)];
}
function hexdistance(x1,y1,x2,y2){
	var z1=-x1-y1;
	var z2=-x2-y2;
	return (Math.abs(x1 - x2) + Math.abs(y1 - y2) + Math.abs(z1 - z2)) / 2;
}
function keydistance(key1,key2){
	var a1=keytoloc(key1);
	var a2=keytoloc(key2);
	return hexdistance(a1[0],a1[1],a2[0],a2[1]);
}
function indexOfMax(arr) {
	if (arr.length === 0) {
		return -1;
	}
	var max = arr[0];
	var maxIndex = 0;
	for (var i = 1; i < arr.length; i++) {
		if (arr[i] > max) {
			maxIndex = i;
			max = arr[i];
		}
	}
	return maxIndex;
}
Grid.prototype.scoreDict = function(){
	var influence={};
	for (var loc in this.map){
		influence[loc]={};
		for (var move in this.map){
			if (this.map[move]){
				influence[loc][this.map[move]]?influence[loc][this.map[move]]+=1/(keydistance(loc,move)+1):influence[loc][this.map[move]]=1/(keydistance(loc,move)+1);
			}
		}
	}
	var s={};
	for (var l in influence){
		var high=0;
		var cols=[];
		for (var m in influence[l]){
			
			if (influence[l][m]>high){
				high=influence[l][m];
				cols=[m];
			} else if (influence[l][m]==high){
				cols.push(m);
			}
		}
		for (var c in cols){
			
			s[cols[c]]?s[cols[c]]+=1:s[cols[c]]=1;
		}
	}
	this.influence=influence;
	return s;
};
Grid.prototype.score = function(){
	var s=this.scoreDict();
	var svals=[];
	var scols=[];
	for (var d in s){
		svals.push(s[d]);
		scols.push(d);
	}
	var svalsorted=[];
	var scolsorted=[];
	for (var i=0;i<svals.length;i++){
		var im=indexOfMax(svals);
		svalsorted.push(svals[im]);
		scolsorted.push(scols[im]);
		svals[im]=-1;
	}
	return [svalsorted,scolsorted];
};
Grid.prototype.letAIplay = function(){
	var col=document.getElementById("col").value;
	var bests=0;
	var bestloc="";
	var dict=this.scoreDict();
	var scorenow=dict[col]||0;
	for (var loc in this.map){
		if (this.map[loc]==""){
			this.map[loc]=col;
			var dscore=this.scoreDict()[col]-scorenow;
			if (dscore>bests){
				bests=dscore;
				bestloc=loc;
			}
			this.map[loc]="";
		}
	}
	if (bests>0){
		var l=keytoloc(bestloc);
		document.getElementById("y").value=l[0];
		document.getElementById("x").value=l[1];
		this.submit();
	} else {
		alert("The AI passes.");
	}
};
Grid.prototype.submit = function(){
	var x = document.getElementById("y").value;
	var y = document.getElementById("x").value;
	if (this.map[[x,y]]){
		alert(x+", "+y+" is already occupied by "+this.map[[x,y]]);
		return 0;
	}
	if (typeof(this.map[[x,y]])==='undefined'){
		return 0;	
	}
	this.map[[x,y]]=document.getElementById("col").value;
	var cols=document.getElementById("cols").value.split(',');
	var c=cols.shift();
	document.getElementById("col").value=c;
	cols.push(c);
	document.getElementById("cols").value=cols.join();
	this.drawGrid();
}
