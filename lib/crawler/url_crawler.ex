defmodule Crawler.UrlCrawler do

	import Crawler.HrefExtractor, only: [ extract_hrefs: 1 ]

	def greet(scheduler_pid) do
		send scheduler_pid, { :ready, self }
		receive do
			{ :crawl, url, client } ->
				send client, { :answer, crawl_url(url) }
				greet(scheduler_pid)

			{ :shutdown } -> 
				exit(:normal)
		end
	end

	def crawl_url(url) do
		IO.puts "Crawling " <> url
		
		html = fetch_url(url)
		hrefs = extract_hrefs(html)

		formatted_hrefs = format_hrefs(url, hrefs)
		# remove duplicates
		Enum.uniq(formatted_hrefs)
	end

	def fetch_url(url) do
		response = HTTPotion.get(url)
		response.body
	end

	def format_hrefs(baseurl, hrefs) do
		formatted_hrefs = Enum.map(hrefs, fn(href) -> 
			is_relative_url = String.starts_with? href, ["/"]

			if is_relative_url do
				formatted_href = baseurl <> href
			else
				formatted_href = href
			end

			formatted_href
		end)

		formatted_hrefs
	end

end