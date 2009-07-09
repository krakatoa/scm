# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format 
# (all these examples are active by default):
 ActiveSupport::Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1es'
#   inflect.singular /^(ox)es/i, '\1'
   inflect.irregular 'vigilador', 'vigiladores'
#   inflect.uncountable %w( fish sheep )
 end
