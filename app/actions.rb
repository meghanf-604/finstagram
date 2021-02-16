helpers do
    def current_user
        User.find_by(id: session[:user_id])
    end

    # def logged_in?
    #     !!current_user
    # end
end
#/conditional login
# before '/finstagrampost_new' do
#     redirect to ('/login') unless logged_in?
# end

get '/' do
  @finstagram_posts = FinstagramPost.order(created_at: :desc)
#   @current_user = User.find_by(id: session[:user_id])
  erb(:index)
end

get '/signup' do     # if a user navigates to the path "/signup",
  @user = User.new   # setup empty @user object
  erb(:signup)       # render "app/views/signup.erb"
end

get '/finstagram_posts/new' do
    @finstagram_post = FinstagramPost.new
    erb(:"finstagram_posts/new")
end

get '/finstagram_posts/:id' do
    # halt(404, erb(: 'errors/404')) unless !FinstagramPost.where(id: params[:id}).empty?

    @finstagram_post = FinstagramPost.find(params[:id])
    erb(:"finstagram_posts/show")
end

post '/finstagram_posts' do
  photo_url = params[:photo_url]

  @finstagram_post = FinstagramPost.new({ photo_url: photo_url, user_id: current_user.id })

  if @finstagram_post.save
    redirect(to('/'))
  else
    erb(:"finstagram_posts/new")
  end
end

post '/signup' do
  email      = params[:email]
  avatar_url = params[:avatar_url]
  username   = params[:username]
  password   = params[:password]

  @user = User.new({ email: email, avatar_url: avatar_url, username: username, password: password })

  if @user.save
    redirect to ('/login')
  else
    erb(:signup)
  end
end

get '/login' do
    erb(:login)
end

post '/login' do
    username = params[:username]
    password = params[:password]

    user = User.find_by(username: username)

    # if user && user.password == password
    if user && user.authenticate(password)
        session[:user_id] = user.id
        redirect to('/')
        # "Success! User with id #{session[:user_id]} is logged in!"
    else
       @error_message = "Login failed."
       erb(:login)
    end
end 

    get '/logout' do  
        session[:user_id] = nil
        redirect to('/')
end

post '/comments' do
    text = params[:text]
    finstagram_post_id = params[:finstagram_post_id]

    comment = Comment.new({ text: text, finstagram_post_id: finstagram_post_id, user_id: current_user.id})

    comment.save

    redirect(back)
end

post '/likes' do
    finstagram_post_id = params[:finstagram_post_id]

    like = Like.new({ finstagram_post_id: finstagram_post_id, user_id: current_user.id})

    like.save

    redirect(back)
end

delete '/likes/:id' do
    like = Like.find(params[:id])
    like.destroy
    redirect(back)
end
