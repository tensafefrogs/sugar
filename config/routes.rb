ActionController::Routing::Routes.draw do |map|

    # Discussions search
	#map.connect '/search/:query/:page', :controller => 'discussions', :action => 'search'
	map.formatted_search_with_query '/search/:query.:format', :controller => 'discussions', :action => 'search'
	map.search_with_query '/search/:query', :controller => 'discussions', :action => 'search'
	map.search  '/search', :controller => 'discussions', :action => 'search'

    # Posts search
	map.connect '/posts/search/:query/:page', :controller => 'posts', :action => 'search'
    map.connect '/posts/search/*query', :controller => 'posts', :action => 'search'
    map.search_posts '/posts/search', :controller => 'posts', :action => 'search'

	map.connect '/discussions/:id/search_posts/*query', :controller => 'discussions', :action => 'search_posts'

	# Users
    map.resources(
        :users,
        :member => {
			:participated   => :get, 
			:discussions    => :get, 
			:posts          => :get, 
			:update_openid  => :any,
			:grant_invite   => :any,
			:revoke_invites => :any,
			:stats          => :any
		},
        :collection => { 
			:login                 => :any,
			:logout                => :any, 
			:password_reset        => :any, 
			:complete_openid_login => :any,
			:facebook_login        => :any,
			:connect_facebook      => :any,
			:disconnect_facebook   => :any,
			# Lists
			:xboxlive              => :get, 
			:twitter               => :get, 
			:online                => :get, 
			:recently_joined       => :get,
			:admins                => :get,
			:top_posters           => :get,
			:trusted               => :get,
			:map                   => :get,
			:banned                => :any
		}
    )
	map.grant_invite_user   '/users/profile/:id/grant_invite',       :controller => 'users', :action => 'grant_invite'
	map.revoke_invites_user '/users/profile/:id/revoke_invites',     :controller => 'users', :action => 'revoke_invites'
	map.update_openid_user  '/users/profile/:id/update_openid',      :controller => 'users', :action => 'update_openid'
	map.edit_user           '/users/profile/:id/edit',               :controller => 'users', :action => 'edit'
	map.edit_user_page      '/users/profile/:id/edit/:page',         :controller => 'users', :action => 'edit'
	map.user_profile        '/users/profile/:id',                    :controller => 'users', :action => 'show'
    map.discussions_user    '/users/profile/:id/discussions',        :controller => 'users', :action => 'discussions'
    map.connect             '/users/profile/:id/discussions/:page',  :controller => 'users', :action => 'discussions'
    map.participated_user   '/users/profile/:id/participated',       :controller => 'users', :action => 'participated'
    map.connect             '/users/profile/:id/participated/:page', :controller => 'users', :action => 'participated'
    map.posts_user          '/users/profile/:id/posts',              :controller => 'users', :action => 'posts'
    map.paged_user_posts    '/users/profile/:id/posts/:page',        :controller => 'users', :action => 'posts'
    map.stats_user          '/users/profile/:id/stats',              :controller => 'users', :action => 'stats'
	map.new_user_by_token   '/users/new/:token',                     :controller => 'users', :action => 'new'

	# Categories
    map.resources(
        :categories
    )
    map.connect '/categories/:id/:page', :controller => 'categories', :action => 'show'

	# Messages
    map.resources(
        :messages,
        :collection => { :outbox => :any, :conversations => :any }
    )
    map.paged_messages              '/messages/inbox/:page', :controller => 'messages', :action => 'index'
    map.paged_sent_messages         '/messages/outbox/:page', :controller => 'messages', :action => 'outbox'
    map.user_conversation           '/messages/conversations/:username', :controller => 'messages', :action => 'conversations'
    map.paged_user_conversation     '/messages/conversations/:username/:page', :controller => 'messages', :action => 'conversations'
    map.last_user_conversation_page '/messages/conversations/:username/last', :controller => 'messages', :action => 'conversations', :page => :last

	# Discussions
    map.resources(
        :discussions,
        :collection => {:participated => :any, :search => :any, :following => :any, :favorites => :any},
		:member     => {:follow => :any, :unfollow => :any, :favorite => :any, :unfavorite => :any, :search_posts => :any, :mark_as_read => :any}
    ) do |discussions|
        discussions.resources(
            :posts,
            :member     => { :quote => :any },
            :collection => { :doodle => :post, :count => :any, :since => :any, :preview => :any }
        )
    end
	map.connect           '/discussions/:discussion_id/posts/since/:index', :controller => 'posts',       :action => 'since'
    map.paged_discussions '/discussions/archive/:page',                     :controller => 'discussions', :action => 'index'
    map.paged_discussion  '/discussions/:id/:page',                         :controller => 'discussions', :action => 'show'

	# Invites
	map.resources(
		:invites,
		:collection => {:all => :get},
		:member => {:accept => :get}
	)
	
	map.resources :notifications

	map.resource :admin, :member => {:configuration => :any}, :controller => 'admin'


    # Vanilla redirects
    map.with_options :controller => 'vanilla' do |vanilla|
        vanilla.connect '/vanilla',              :action => 'discussions'
        vanilla.connect '/vanilla/index.php',    :action => 'discussions'
        vanilla.connect '/vanilla/comments.php', :action => 'discussion'
        vanilla.connect '/vanilla/account.php',  :action => 'user'
    end

    # Install the default routes as the lowest priority.
    map.connect ':controller/:action/:id'
    map.connect ':controller/:action/:id.:format'

	# Root
    map.root :controller => 'discussions', :action => 'index'
end