defmodule UrlCrawlerTest do
	use ExUnit.Case

	import Crawler.UrlCrawler, only: [ crawl_url: 1, fetch_url: 1, format_hrefs: 2 ]

	# test "fetching a site" do
	# 	# response = HTTPotion.get("http://erlang.org")
	# 	# assert response.body == true
	# 	hrefs = crawl_url("http://nandreasson.se")
	# 	assert hrefs == ["facebook.com"]
	# end
	
	test "fetch url" do # html = fetch_url("http://nandreasson.se/about") HTTPotion.start
		response = HTTPotion.get("http://nandreasson.se/about") 
		IO.inspect response.headers

		status_code = response.status_code
		IO.puts status_code

		{:Location, redirect_url} = List.keyfind(response.headers, :Location, 0)
		IO.puts redirect_url


		IO.inspect response
		html = response.body
		assert html == "hej"
	end


	# test "format hrefs" do
	# 	hrefs = [ "/test", "http://facebook.com"]

	# 	formatted_hrefs = format_hrefs("http://nandreasson.se", hrefs)
	# 	assert formatted_hrefs == ["http://nandreasson.se/test", "http://facebook.com"]
	# end

	# test "fetch and stuff" do
	# 	hrefs = crawl_url("http://nandreasson.se")	

	# 	assert hrefs == []
	# end
end