portfolio = require './portfolio.coffee'
math = require 'mathjs'
request = require 'request'
chalk = require 'chalk'
numeral = require 'numeral'
Table = require 'tty-table'
tableHeader = [
  {
    value : "idx",
    alias: "#",
    headerColor : "cyan",
    color: "white",
    width: 7,
    align: "center"
  },
  {
    value : "symbol",
    alias: "Symbol",
    headerColor : "cyan",
    color: "white",
    align: "left",
    width: 25,
    paddingLeft: 1
  },
  {
    value : "exchange",
    alias: "Exchange",
    headerColor : "cyan",
    color: "white",
    width: 15
  },
  {
    value : "unit",
    alias: "Units",
    headerColor : "cyan",
    color: "cyan",
    width: 10,
    align: "center"
  },
  {
    value : "buyPrice",
    alias: "Buy Price ",
    headerColor : "cyan",
    color: "white",
    formatter: (v) -> numeral(v).format('0,0.00')
  },
  {
    value : "ltp",
    alias: "LTP  ",
    headerColor : "cyan",
    color: "white",
    formatter: (v) -> numeral(v).format('0,0.00')
  },
  {
    value : "investment",
    alias: "Investment  ",
    headerColor : "cyan",
    color: "white",
    formatter: (v) -> numeral(v).format('0,0.00')
  },
  {
    value : "value",
    alias: "Current Value  ",
    headerColor : "cyan",
    color: "white",
    formatter: (v) -> numeral(v).format('0,0.00')
  },
  {
    value : "pl",
    alias: "P/L  ",
    headerColor : "cyan",
    color: "white",
    formatter : (v) ->
      vstr = numeral(v).format('0,0.00')
      return if v >= 0 then chalk.green(vstr) else chalk.red(vstr)
  },
  {
    value : "weightedUnits",
    alias: "Weighted Units",
    headerColor : "cyan",
    color: "yellow"
  },
  {
    value : "weightedLtp",
    alias: "Weighted LTP  ",
    headerColor : "cyan",
    color: "yellow",
    formatter: (v) -> numeral(v).format('0,0.00')
  }
]

ltpList = {}
queryString = ''
queryString += scrip.exchange + ":" + scrip.symbol + ',' for scrip in portfolio
queryString = queryString.slice 0, -1
hcf = math.gcd (scrip.unit for scrip in portfolio)...
colTotals = {
  idx: 0,
  symbol: 'Totals:',
  exchange: ' ',
  unit: 0,
  buyPrice: 0.0,
  ltp: 0.0,
  investment: 0.0,
  value: 0.0,
  pl: 0.0,
  weightedUnits: 0,
  weightedLtp: 0.0
}


request 'http://www.google.com/finance/info?q='+queryString, (e, r, body) =>
  console.log "!!!!!ERROR: "+ e if e
  j = JSON.parse(body.replace("//",""))
  ltpList[i.t] = i.l for i in j
  for scrip, idx in portfolio
    scrip.idx = idx + 1
    scrip.ltp = Number ltpList[scrip.symbol]
    scrip.investment = (scrip.unit * scrip.buyPrice).toFixed(2)
    scrip.value = (scrip.unit * scrip.ltp).toFixed(2)
    scrip.pl = (scrip.unit * (scrip.ltp - scrip.buyPrice)).toFixed(2)
    scrip.weightedUnits = Math.ceil(scrip.unit / hcf)
    scrip.weightedLtp = (scrip.weightedUnits * scrip.ltp).toFixed(2)
    ## colTotals
    colTotals[key] += Number scrip[key] for key,val of scrip when key not in ['symbol', 'exchange', 'idx']

  colTotals.idx = idx + 1
  portfolio.push colTotals

  table = new Table tableHeader, portfolio, {
    borderStyle : 1,
    paddingBottom : 0,
    headerAlign : "center",
    align : "right",
    color : "white"
  }
  console.log table.render()
