require 'fiddle'
require 'fiddle/import'

module DictAPI
  extend Fiddle::Importer
  dlload "C:\\Program Files (x86)\\Google\\Google Pinyin 2\\gpy_dict_api.dll"
  extern 'int ImportDictionary(wchar_t*)'
end

path = "E:\\zh99998\\WebstormProjects\\NekoIME\\result.dic"
path.encode!("UTF-16LE")
DictAPI.ImportDictionary(path)