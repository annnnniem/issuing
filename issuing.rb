require 'sinatra'
require 'dotenv/load'
require 'json'
require 'intercom'
require "sinatra/reloader"

def initialize_intercom
	if @intercom.nil? then
		token = ENV['token']
		@intercom = Intercom::Client.new(token: token)
	end
end

get '/' do 
	erb :index
end

post '/' do 
	#array to hold the convos
	@github_convos = []
	#get the user id from the field input
	@id = params[:id]
	initialize_intercom
	list_conversations(@id)
	@conversations.each do |i|
		convo = get_conversation(i)
		parts = get_parts(convo)
		check_parts_for_string(parts)
	end
	erb :issues
end

def list_conversations(id)
	@conversations = @intercom.conversations.find_all(:type => 'user', :intercom_user_id => id)
end

def get_conversation(conversation)
	@convo = @intercom.conversations.find(:id => conversation.id)
end
	
def get_parts(conversation)
	@array_of_notes = conversation.conversation_parts.reject { |part| part.part_type != 'note' && part.author != 'bot'}
end

def check_parts_for_string(parts)
	parts.each_with_index do |m|
		if m.body.include? "https://github.com"
			regex = /(https?:\/\/github.com\/\S*\/\S*\/issues\/1)/
			@url = regex.match(m.body)
			convo_id = @convo.id.to_i
			hashbrowns = { "id" => @convo.id, "url" => @url}
			@github_convos << hashbrowns
			puts @github_convos
		else
			break
		end
	end
end

#to do
# * validate the user


