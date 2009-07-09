ActionController::Routing::Routes.draw do |map|
  map.resource :account, :controller => "users"
  map.resources :users

  map.signup '/signup', :controller => 'users', :action => 'new'
  map.login '/login', :controller => 'user_sessions', :action => 'new'
  map.logout '/logout', :controller => 'user_sessions', :action => 'destroy'
  map.resource :user_session

  map.resources :vigiladores, :member => {  :alta => :get,
                                            :no_ingreso => :get,
                                            :aplicar_gestion_tramites => :post,
                                            :descontar_cuotas => :post,
                                            :desbloquear => :post }

  map.modificar_porcentaje_gestion 'admin/modificar_porcentaje_gestion', :controller => "admin", :action => "modificar_porcentaje_gestion", :method => :post

  map.recursos_humanos '/recursos_humanos/:id', :controller => 'vigiladores', :action => 'recursos_humanos'
  map.sueldos '/sueldos/:id', :controller => 'vigiladores', :action => 'sueldos'
  map.logistica '/logistica/:id', :controller => 'vigiladores', :action => 'logistica'
  map.contabilidad '/contabilidad/:id', :controller => 'vigiladores', :action => 'contabilidad'
  map.resumen '/resumen/:id', :controller => 'vigiladores', :action => 'resumen'

  map.resources :datos, :member => { :facturar => :post }
  map.root :controller => "vigiladores", :action => "index"
end
