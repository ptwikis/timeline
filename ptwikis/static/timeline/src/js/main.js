//Variables of global context
var serie = [], series = [], scales = [], data2, graph, legend, annotator, slider;
var palette = new Rickshaw.Color.Palette( { scheme: 'spectrum14' } );

function data_render(data_file){
    d3.tsv(data_file, function(error, data){  
	if(error) return console.warn(error);

	var dataParser = d3.time.format("%b-%Y").parse;

	data.reverse();
	var keys = [];

	Object.keys(data[0]).forEach(function(d){
	    serie.push([]);
	    keys.push(d);
	});

	keys.reverse();
	keys.pop();

	data2 = data;

	data.forEach(function(d){
	    var date = dataParser(d.date).getTime()/1000;
	    
	    for(var k = 0; k < keys.length; k++){
		serie[k].push({ x: date, y: +d[keys[k]] });
	    }
	});


	for(var k = 0; k < keys.length; k++){
	    series.push({ name: keys[k], data: serie[k], color: palette.color() });
	}

	graph = new Rickshaw.Graph({
	    element: document.getElementById("chart"),
	    width: document.body.clientWidth * 0.75,
	    renderer: 'line',
	    stroke: true,
	    height: 250,
	    series: series
	});

	graph.render();
	var monthName = ["Jan", "Fev", "Mar","Abr","Mai","Jun","Jul","Ago","Set","Out", "Nov", "Dez"];

	var hoverDetail = new Rickshaw.Graph.HoverDetail( {
	    graph: graph,
	    yFormatter: function(y) { return y},
	    xFormatter: function(x){
			var d = new Date(x * 1000);
			return String(monthName[d.getMonth()] + "/" + d.getFullYear());
	    }
	});

	legend = new Rickshaw.Graph.Legend( {
	    element: document.getElementById('legend'),
	    graph: graph
	});    

	annotator = new Rickshaw.Graph.Annotate( {
	    graph: graph,
	    element: document.getElementById('timeline')
	});

	var shelving = new Rickshaw.Graph.Behavior.Series.Toggle( {
	    graph: graph,
	    legend: legend
	});

	var order = new Rickshaw.Graph.Behavior.Series.Order( {
	    graph: graph,
	    legend: legend
	});

	var ticksTreatment = 'glow';

	var xAxis = new Rickshaw.Graph.Axis.Time( {
	    graph: graph
	});

	xAxis.render();

	var yAxis = new Rickshaw.Graph.Axis.Y( {
	    graph: graph,
	    orientation: "right",
	    tickFormat: Rickshaw.Fixtures.Number.formatKMBT,
	    ticksTreatment: ticksTreatment
	});

	yAxis.render();

	slider = new Rickshaw.Graph.RangeSlider( {
	    graph: graph,
	    element: $('#slider')
	});

	graph.update();

create_dyn_form(series);//cria form de dados dinamicos

    });

}

function events_render(file_name){
    d3.json(file_name, function(error, events){
	if(error) console.warm(error);
	window.events = events;

	var dataParse = d3.time.format("%Y-%m").parse;
	//console.log("-------");
	window.events.vandalismo.forEach(function(d){
	    annotator.add(dataParse(d.date)/1000, d.event);
	});

	annotator.update();
    });
}

function switch_events(event_tag){
    var events = document.getElementById("timeline");
    events.innerHTML = "";

    annotator = new Rickshaw.Graph.Annotate( {
	graph: graph,
	element: document.getElementById('timeline')
    });

    var dataParse = d3.time.format("%Y-%m").parse;

    window.events[event_tag].forEach(function(d){
	annotator.add(dataParse(d.date)/1000, d.event);
    });

    annotator.update();
	graph.render();
}

function data_render_dyn(param1, param2, param3){
	var param1index = 0;
	var param2index = 0;
	var q = series.length;

	for(var k = 0; k < q; k++){
 		if (param1 == series[k]["name"]) {
  			param1index = k;
 	}

 	if (param2 == series[k]["name"]) {
  		param2index = k;
 	}
}

var novaLinha = {name: series[param1index]["name"]+param3+series[param2index]["name"], data: [] , color: palette.color() };

for(var k = 0; k < series[0]["data"].length; k++){
 valorX = series[param1index]["data"][k]["x"];


switch(param3){

 case "/":
  if(series[param2index]["data"][k]["y"] == 0){
   valorY = 0;
  }else{
   valorY = series[param1index]["data"][k]["y"]/series[param2index]["data"][k]["y"];
  }
  break;
 case "*":
     valorY = series[param1index]["data"][k]["y"]*series[param2index]["data"][k]["y"];
  break;
 case "+":
     valorY = series[param1index]["data"][k]["y"]+series[param2index]["data"][k]["y"];
  break;
 case "-":
     valorY = series[param1index]["data"][k]["y"]-series[param2index]["data"][k]["y"];
  break;

}//fecha switch

 novaLinha["data"].push({x: valorX, y: valorY});
}//fecha for

series.push(novaLinha);

recreate_graph();
create_dyn_form(series);//recria form de dados dinamicos
}

function recreate_graph(){

graph.update();

document.getElementById("legend").innerHTML = "";

var legend = new Rickshaw.Graph.Legend( {
	    element: document.getElementById('legend'),
	    graph: graph
	});  
var shelving = new Rickshaw.Graph.Behavior.Series.Toggle( {
	    graph: graph,
	    legend: legend
	});

var order = new Rickshaw.Graph.Behavior.Series.Order( {
	    graph: graph,
	    legend: legend
	});
}

function create_dyn_form(series){

document.getElementById("legenddyn").innerHTML = "";

textoForm = '      <div id="legend2" class="section">Gerar dados Dinâmicos	 <form id="dynamicdata" name="dynamicdata_selector">  <select id="dynval1"  name="val1">';

var q = series.length;
for(var k = 0; k < q; k++){
textoForm += '<option value="';
textoForm += series[k]["name"];
if (series[k]["name"] == "EdiçõesMês"){textoForm += '" selected="selected">'}else{textoForm += '">';}
textoForm += series[k]["name"];
textoForm += '</option>';
}
textoForm += ' </select> <select id="dynval3" name="val3"><option value="+">+</option><option value="-">-</option><option value="*">*</option><option value="/" selected="selected">/</option></select> <select id="dynval2" name="val2">';
for(var k = 0; k < q; k++){
textoForm += '<option value="';
textoForm += series[k]["name"];
if (series[k]["name"] == "Ativos"){textoForm += '" selected="selected">'}else{textoForm += '">';}
textoForm += series[k]["name"];
textoForm += '</option>';
}

textoForm += ' </select> <input type="button" onclick="data_render_dyn(document.getElementById('+"'dynval1').value,document.getElementById('dynval2').value,document.getElementById('dynval3').value)"+ '" value="Gerar"> </form>';

textoForm += 'Dados de Wikiprojetos: <select onchange="data_render_new(value)"><option>WikiProjetos</option> <option value="saude">Saúde</option> </select>';
//prever na linha acima a adicao futura de novos datasets e gerar options a partir da lista deles em uma pasta

document.getElementById("legenddyn").innerHTML = textoForm;

}


function data_render_new(projeto){

 var data_file = "/ptwikis/static/timeline/data/"+projeto+"/"+projeto+"_data.tsv";

d3.tsv(data_file, function(data) { 

tamanho = Object.keys(data[0]).length;
nomes = Object.getOwnPropertyNames(data[0]);
meses = Object.keys(data).length;

data.reverse();

for (var z = 0; z < tamanho; z++){
 nome = nomes[z];
 if (nome != "date"){
  var novaLinha = {name: nome, data: [] , color: palette.color() };
  for(var k = 0; k < meses; k++){
   valorX = series[0]["data"][k]["x"];
   valorY = Number(data[k][nome]);
   novaLinha["data"].push({x: valorX, y: valorY});
  } //fecha for k
  series.push(novaLinha);
 }// fecha if
} // fecha for z

recreate_graph();
create_dyn_form(series);//recria form de dados dinamicos

}); //fecha d3.tsv


} //fecha funcao create_saude

data_render("/ptwikis/static/timeline/data/linha_data.tsv");
events_render("/ptwikis/static/timeline/data/events.json");

