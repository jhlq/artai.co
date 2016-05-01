function putborder(l,map,col=''){
	//l=map.l
	if (l==1){
		map[[0,0]]=col
	} else {
		var dirs=[[0,1],[1,0],[1,-1],[0,-1],[-1,0],[-1,1]]
		loc=[-l+1,0]
		for (i = 0; i < 6; i++) { 
			for (j = 0; j < l-1; j++) { 
				map[loc]=col
				loc[0]+=dirs[i][0]
				loc[1]+=dirs[i][1]
			}
		}
	}
	return map
}
function putboard(l,map){
	for (k=1;k<=l;k++){
		putborder(k,map)
	}
	return map
}



// For canvas

function Grid(canvasId, l) {
	this.canvasOriginX = 9;
	this.canvasOriginY = 35;
	
	this.map={};
	putboard(l,this.map);
	this.canvas = document.getElementById(canvasId);
	this.context = this.canvas.getContext('2d');

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
};

Grid.prototype.drawLine = function(x0, y0, x1, y1, col="#000", text="") {
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
Grid.prototype.drawGridLine=function(offset,lineWidth=1,ax='x',col="#000",text="",clearfirst=false){
	if (clearfirst){
		this.drawGrid();
	}
	this.context.lineWidth=lineWidth;
	this.context.strokeStyle = col;
	var sl=(this.l-1)*this.d;
	var h=Math.sin(Math.PI/3)*this.d
	var ssl=Math.sin(Math.PI/3)*sl
	var csl=Math.cos(Math.PI/3)*sl
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
}
Grid.prototype.drawGrid = function() {
	this.context.clearRect(0, 0, this.canvas.width, this.canvas.height);
	this.context.strokeStyle='#000';
	this.context.lineWidth=1;
	this.drawLine(this.x0-this.sl,this.y0,this.x0+this.sl,this.y0);
	this.drawLine(this.x0-this.csl,this.y0+this.ssl,this.x0+this.csl,this.y0-this.ssl);
	this.drawLine(this.x0+this.csl,this.y0+this.ssl,this.x0-this.csl,this.y0-this.ssl);
	for (i = 1; i < this.l; i++) {
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

	for (key in this.map){
		if (this.map[key]){
			this.drawCircleKey(key,this.map[key]);
		}
	}
	var o=document.getElementById('x').value;
	grid.drawGridLine(o,3,'x',"#909",o);
	var o=document.getElementById('y').value;
	grid.drawGridLine(o,3,'y',"#909",o);
}
Grid.prototype.drawCircle=function(x,y,col){
	//this.context.strokeStyle='#000';//document.getElementById("col").value;
	this.context.fillStyle=col;//document.getElementById("col").value;
	this.context.beginPath();
	this.context.arc(x,y,this.d/2,0,2*Math.PI);
	//this.context.stroke();
	this.context.fill();

}
Grid.prototype.drawCircleKey=function(key,col){
	xy=key.split(',');
	//console.log(xy)
	this.drawCircleAt(parseInt(xy[0]),parseInt(xy[1]),col);
}
Grid.prototype.drawCircleAt=function(xi,yi,col){
	var x=this.x0+xi*this.d+yi*this.yvec[0];
	var y=this.y0-yi*this.yvec[1];
	//console.log(x,y)
	this.drawCircle(x,y,col);
}
function distance(x1,y1,x2,y2){
	return Math.sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2))
}
Grid.prototype.clickEvent = function (e) {
	var mouseX = e.pageX;
	var mouseY = e.pageY;
	var localX = mouseX - this.canvasOriginX;
	var localY = mouseY - this.canvasOriginY;
	for (key in this.map){
		var xy=key.split(',');
		var x=this.x0+parseInt(xy[0])*this.d+parseInt(xy[1])*this.yvec[0];
		var y=this.y0-parseInt(xy[1])*this.yvec[1];
		if (distance(localX,localY,x,y)<this.d/2){
			//console.log(key);
			document.getElementById("x").value=xy[1];
			document.getElementById("y").value=xy[0];
			document.getElementById("x").onchange();
			this.drawCircle(x,y,document.getElementById("col").value);
			break;
		}
	}
/*
	var tile = this.getSelectedTile(localX, localY);
	if (tile.column >= 0 && tile.row >= 0) {
		var drawy = tile.column % 2 == 0 ? (tile.row * this.height) + this.canvasOriginY : (tile.row * this.height) + this.canvasOriginY + (this.height / 2);
		var drawx = (tile.column * this.side) + this.canvasOriginX;
	var p = document.getElementById("player").value;
	var ps = document.getElementById("players").value;
	var c=(document.getElementById("colors").value).split(";");
	this.drawHex(drawx, drawy, "rgba("+c[p]+",0.3)", "");
	if (ps!=1){
		document.getElementById("player").value=(Number(p)+1)%ps;
	}
	document.getElementById("plays").value+=p+":"+tile.column+","+tile.row+";";
	} 
*/
};
