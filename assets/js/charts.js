// Visualizations of sentiment
//
//
var d3 = require('d3');

// sentiment histogram
export function histogram(data) {
  // expects a list of three-element lists: [beginning, end, count]
  //
  var margin = {top: 20, right: 20, bottom: 110, left: 60},
    width = 800 - margin.left - margin.right,
    height = 400 - margin.top - margin.bottom;

  var x = d3.scaleBand()
    .domain(data.map(d => d[0]))
    .rangeRound([0, width])
    .padding(0.1);

  var y = d3.scaleLinear()
    .domain([0, d3.max(data.map(d => d[2]))])
    .rangeRound([height, 0]);

  console.log(x.bandwidth())

  d3.select("#sentiment-histogram").selectAll("svg").remove()

  var svg = d3.select("#sentiment-histogram").append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
    .append("g")
      .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

  svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + height + ")")
      .call(d3.axisBottom(x)
        .ticks(data)
        .tickFormat((d, i) => data[i][0].toFixed(2) + " to " + data[i][1].toFixed(2)))
      //.call(g => g.select(".domain").remove())
    .selectAll("text")
      .style("text-anchor", "end")
      .attr("dx", "-.8em")
      .attr("dy", "-.55em")
      .attr("transform", "rotate(-90)" );

  svg.append("text")
    .attr("transform",
          "translate(" + (width/2) + " ," +
                         (height + margin.top + 80) + ")")
    .style("text-anchor", "middle")
    .text("Sentiment");

  svg.append("g")
      .attr("class", "y axis")
      .call(d3.axisLeft(y))
    .append("text")
      .attr("transform", "rotate(-90)")
      .attr("y", 6)
      .attr("dy", ".71em")
      .style("text-anchor", "end");

  // text label for the y axis
  svg.append("text")
      .attr("transform", "rotate(-90)")
      .attr("y", 0 - margin.left)
      .attr("x",0 - (height / 2))
      .attr("dy", "1em")
      .style("text-anchor", "middle")
      .text("Number of Tweets");

  svg.selectAll("bar")
    .data(data)
    .enter().append("rect")
      .attr("class", "bar")
      .style("fill", "#4B0082")
      .attr("border", 5)
      .attr("x", d => x(d[0]))
      .attr("width", x.bandwidth())
      .attr("y", d => y(d[2]))
      .attr("height", d => height - y(d[2]));

}
