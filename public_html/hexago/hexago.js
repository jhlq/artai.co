function putborder(l,map,col='#000'){
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

function Grid(map,canvasId, l) {
	/*
	this.radius = radius;

	this.height = Math.sqrt(3) * radius;
	this.width = 2 * radius;
	this.side = (3 / 2) * radius;

	
	this.canvasOriginX = 0;
	this.canvasOriginY = 0;
	*/
	this.map=map
	this.canvas = document.getElementById(canvasId);
	this.context = this.canvas.getContext('2d');

	this.d=this.canvas.width/(2*l+1);
	this.l=l;
	this.yvec=[this.d/2,this.d*Math.sin(Math.PI/3)];
	
	//this.canvas.addEventListener("mousedown", this.clickEvent.bind(this), false);
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
		this.context.fillText(text, x0 + (this.d / 2) - (this.d/4), y0 + (this.d - 5));
	}
};
Grid.prototype.drawGrid = function() {
	var x0=this.canvas.width/2;
	var y0=this.canvas.height/2;
	var sl=(this.l-1)*this.d;
	var h=Math.sin(Math.PI/3)*this.d
	var ssl=Math.sin(Math.PI/3)*sl
	var csl=Math.cos(Math.PI/3)*sl
	this.drawLine(x0-sl,y0,x0+sl,y0);
	this.drawLine(x0-csl,y0+ssl,x0+csl,y0-ssl);
	for (i = 1; i < this.l; i++) {
		this.drawLine(x0-sl+i*this.d/2,y0+i*h,x0+sl-i*this.d/2,y0+i*h);
		this.drawLine(x0-sl+i*this.d/2,y0-i*h,x0+sl-i*this.d/2,y0-i*h);
		this.drawLine(x0-csl-i*this.d/2,y0+ssl-i*h,x0+csl-i*this.d,y0-ssl);
		this.drawLine(x0-csl+i*this.d,y0+ssl,x0+csl+i*this.d/2,y0-ssl+i*h);
	}
	//console.log(ym);
}

