require 'devise_bootstrap_views_helper'

ActiveSupport.on_load(:action_view) { include DeviseBootstrapViewsHelper }
