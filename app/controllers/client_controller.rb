

class ClientController < ApplicationController
  def index
  end
  def submit
  	input= params[:client] [:content]
  	gist=input.split("com/").last
  	uri=URI.parse("https://api.github.com/repos/"+gist+"")
 
  	time = Time.now
  	yest=(time - 1.day).to_time.iso8601
  	week=(time - 7.day).to_time.iso8601
  	per_page=30

	total_issues = main_caller(uri,"",per_page)
	@total=total_issues
	
	issues_day1 = main_caller(uri,yest,per_page)
	@last_24=issues_day1


	issues_7days_ago= main_caller(uri,week,per_page)
	@bw7and1=issues_7days_ago-issues_day1

	@before_7days=total_issues-issues_7days_ago

  end


def main_caller(uri,time_since,per_page)
	count=0
	page=1

	temp=per_page
	while (temp==per_page) do
		temp=0
		temp=find_issues(uri,time_since,page,per_page)
		count+=temp
		page+=1
	end
	return count



end
def find_issues(uri,time_since,page,per_page)
  	
 	
  	http = Net::HTTP.new(uri.host, uri.port)
	http.use_ssl = true
	http.verify_mode = OpenSSL::SSL::VERIFY_NONE

	request = Net::HTTP::Get.new(uri.path)
	if not time_since.nil? || time_since.empty?
		params = {'since' =>time_since,'state'=>'open','page'=>page,'per_page'=>per_page}#,'access_token'=>'e97095172e81c4bce99a1b11cd2518810d83fb8b'}
		request.set_form_data( params )
		request = Net::HTTP::Get.new( uri.path+ '?' + request.body ) 
	else
		params = {'state'=>'open','page'=>page,'per_page'=>per_page}#,'access_token'=>'e97095172e81c4bce99a1b11cd2518810d83fb8b'}
		request.set_form_data( params )
		request = Net::HTTP::Get.new( uri.path+ '?' + request.body ) 
	end

	
	response= http.request(request)
	return respond_parse(response)
  end
 def respond_parse(response)

	res1 = (response.body) && (response.body).length >= 2 ? JSON.parse(response.body) : nil
 		if not  res1[0].nil? 
 			if res1[0]['state'] =='open'
 				return res1.count
 			end
 		end
 	return 0
 end
end
