
class ClientController < ApplicationController
 
  def index
  end

  #function that gets called on submitting github repository link
  #for getting the issue details [counts of open issues in date ranges] 
  def submit
  	input = params[:client][:content]
  	gist = input.split("com/").last
  	uri = URI.parse("https://api.github.com/repos/" + gist + "")
  #current Time ,Time befor 1_day_ago,Time befor 7_day_ago
    time = Time.now
  	yest = (time - 1.day).to_time.iso8601
  	week = (time - 7.day).to_time.iso8601
  	
  #Count of All open issues from now 
  	total_issues = issues(uri, "")
  	@total = total_issues
  	
  #Number of open issues that were opened in the last 24 hours
  	issues_day1 = issues(uri, yest)
  	@last_24 = issues_day1

#Number of open issues that were opened more than 24 hours ago but less than 7 days ago
  	issues_7days_ago= issues(uri,week)
  	@bw7and1=issues_7days_ago-issues_day1
#Number of open issues that were opened more than 7 days ago 
  	@before_7days=total_issues-issues_7days_ago
  end

  #returns paginated issues given the repository url,
  def issues(uri, time_since)
    count=0
    page=1
    per_page = 100
    temp=per_page
    while (temp==per_page) do
    	temp = 0
    	temp = count_issues(uri,time_since,page,per_page)
    	count += temp
    	page += 1
    end
    return count
  end


  #count the issues on repository
  #identified by `uri` in the time period of time_since to now  
  def count_issues(uri, time_since, page, per_page)
    #get all the issues as a json for the time period of time_since to now
    response = get_issues(uri, time_since, page, per_page)
    #Making sure response is valid or is nil
  	response = (response.body) && (response.body).length >= 2 ? JSON.parse(response.body) : nil
 		return response.count unless response.nil? or response[0].nil?
   	return 0
  end

  # returns all the issues given   
  def get_issues(uri, time_since, page, per_page)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(uri.path)
    
    #setting query paramers depending on the time intervel given
    if not time_since.nil? || time_since.empty?
      params = {'since' =>time_since,'state'=>'open','page'=>page,'per_page'=>per_page}#,'access_token'=>'e97095172e81c4bce99a1b11cd2518810d83fb8b'}
    else
      params = {'state'=>'open','page'=>page,'per_page'=>per_page}#,'access_token'=>'e97095172e81c4bce99a1b11cd2518810d83fb8b'}
    end
  
    request.set_form_data( params )
    request = Net::HTTP::Get.new( uri.path+ '?' + request.body ) 
    response = http.request(request)
    return response
  end
end
