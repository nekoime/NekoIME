Server.registerSpider
  interval:5
  name:'GooglePlus'
  displayName:'Google+'
  type:'sns'
  host:'plus.google.com'
  needAuth:true

Server.on 'Spider.runGooglePlus',->
  console.log 'Run G+'
  Server.emit 'Spider.success','GooglePlus'