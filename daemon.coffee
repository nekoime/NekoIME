argv = require('optimist')
  .options('d',{
    alias:'debug'
  })
  .argv
fs = require 'fs'
#Check config.json
fs.writeFileSync('config.json','{}') if !fs.existsSync('config.json')

#--GLOBAL MODULES & CONSTANT & VARIABLE--#
#Logging
logLevel = 'info'
logLevel = 'debug' if argv.debug
global.log = require('tracer').console {
  format:'{{timestamp}} [{{title}}]{{message}}'
  level:logLevel
  dateformat:'yyyy-mm-dd HH:MM:s.l'
}
log.info 'Debug Mode!' if argv.debug

#Utils(like underscore)
global._ = require 'lodash'

#Fibers
global.wait = require 'wait.for'

#Config
global.config = JSON.parse fs.readFileSync 'config.json',encoding:'utf-8'

#--END--#
spiders = {}
exporters = {}
transcoders = {}
#--CREATE EventEmitter--#
{EventEmitter2}=require 'eventemitter2'
global.Server = new EventEmitter2 {
  newListener:false
  maxListeners:20
}

Server.registerSpider=(metadata)->
  spiders[metadata.name] = metadata

Server.removeSpider=(name)->delete spiders[name]
Server.removeExporter=(name)->delete exporters[name]

Server.registerExporter=(metadata)->
  exporters[metadata.name] = metadata

Server.registerTranscoder=(metadata)->
  transcoders[metadata.name] = metadata

Server.on 'Spider.newItem',_.partial(Server.emit,'Analyzer.run')

Server.on 'Spider.error',(error,name)->
  log.error 'Spider %s ran into error.%s',name,error
  spiders[name].running = false
  spiders[name].lastError = error

Server.on 'Spider.success',(name)->
  log.info 'Spider %s done its job.',name
  spiders[name].running = false
  spiders[name].lastError = null



requireAll = require 'require-all'
os = require 'os'
exporterPrefix =
{
  'Windows':'W'
  'Linux':'L'
}[os.type()]

require './lib/analyzer'

requireAll
  dirname:__dirname + '/lib/exporters'
  filter:new RegExp exporterPrefix + '(.+)\.js$'
  excludeDirs:/^\.(git|svn)$/

requireAll
  dirname:__dirname + '/lib/spiders'
  filter:/(.+).js$/
  excludeDirs:/^\.(git|svn)$/

requireAll
  dirname:__dirname + '/lib/transcoders'
  filter:/(.+).js$/
  excludeDirs:/^\.(git|svn)$/

log.info 'All modules loaded. %d exporters found, %d spiders found, %d transcoders found.',_.size(exporters),_.size(spiders),_.size(transcoders)

#--MAIN LOOP--#

log.debug 'Starting main loop.'

##DEBUG ONLY
Server.removeSpider 'GooglePlus'

runSpider = (name)->
  log.debug 'Running spider %s',name
  spiders[name].running = true
  spiders[name].beforeNext = spiders[name].interval
  Server.emit 'Spider.run' + name

mainLoop = ->
  for name,spider of spiders
    break if spider.running
    if not spider.beforeNext?
      runSpider name
    spiders[name].beforeNext -= 1
    runSpider name if spiders[name].beforeNext <= 0

setInterval mainLoop,1000

#--CONFIG SERVER--#

messenger = require('messenger')

confSvr = messenger.createListener 2333

log.info 'Config server listening on port 2333.'