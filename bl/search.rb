

post '/search_ajax' do
	#search by regex
	# sleep(0.3) if !$prod
	criteria = {}
	criteria[:name] = {"$regex" => Regexp.new(params[:name], Regexp::IGNORECASE) } if params[:name].present?
	criteria[:city] = params[:city] if params[:city].present?
	# criteria[:treatments]  = params[:treatments] if params[:treatments][0].present?

  if params[:treatments][0].present?
    criteria[:treatments]  = { '$in': params[:treatments] } 
  else
    criteria[:treatments] = {'$exists': true}
  end

	# criteria[:treatments]  = { '$in': params[:treatments] } if params[:treatments][0].present?
	criteria[:home_visits] = 'true' if (params[:home_visits].to_s == 'true')
	
	users       = $users.get_many(criteria).sample(10).shuffle #.sort_by {|u| u[:create_at]}
    users = users.each  { |user| 
      user['treatments']  = user["treatments"] || []
      user['treatments']  = Array(user["treatments"]).map! {|treatment| t(treatment) }
    	user["treatments"]  = user["treatments"].split(",").join(", ") 
    	user['profession_color'] = user['profession']
      user['profession']  = t(user['profession'])
    	user["home_visits"] = t("performs_home_visits") if user["home_visits"]
    	users
    }

  {users:users}


end

get '/search' do
  erb :"search/search", default_layout 
end 
