defmodule Crawler.UrlCrawler do

	import Crawler.HrefExtractor, only: [ extract_hrefs: 1 ]

	def greet(scheduler_pid) do
		send scheduler_pid, { :ready, self }
		receive do
			{ :crawl, url, client } ->
				send client, { :answer, crawl_url(url) }
				greet(scheduler_pid)

			{ :shutdown } -> 
				IO.puts "Out of business!"
				exit(:normal)
		end
	end

	def crawl_url(url) do
		IO.puts "Crawling " <> url

		html = fetch_url(url)

		hrefs = extract_hrefs(html)

		filtered_hrefs = filter_hrefs(hrefs)

		formatted_hrefs = format_hrefs(url, filtered_hrefs)
		# remove duplicates
		Enum.uniq(formatted_hrefs)
	end

	def fetch_url(url) do
		HTTPotion.start
		response = HTTPotion.get(url)

		status_code = response.status_code	
		IO.puts url
		IO.puts status_code

		if status_code == 301 do
			{:Location, redirect_path} = List.keyfind(response.headers, :Location, 0)
			fqdn = extract_fqdn(url)
			fetch_url( fqdn <> redirect_path )
		else
			response.body
		end

	end

	defp extract_fqdn(url) do
		#name could be http://nandreasson.se, nandreasson.se/ or nandreasson.se/about
		# we only want the http://nandreasson.se
		[procotocol, _, site_name | _] = String.split url, "/"
		fqdn = procotocol <> "//" <> site_name
	end

	def filter_hrefs(hrefs) do
		Enum.filter(hrefs, fn(href) ->

			starts_with_hash = String.starts_with? href, ["#"]
			empty = String.length( String.strip( href ) ) == 0

			cond do
				starts_with_hash == true ->
					false

				empty == true ->
					false

				true ->
					true
			end
		end)	
	end

	def format_hrefs(visited_url, found_hrefs) do
		formatted_hrefs = Enum.map(found_hrefs, fn(href) -> 
			is_root_url = (String.length href) == 1 && String.starts_with? href, ["/"]
			is_relative_url = (String.length href) > 1 && String.starts_with? href, ["/"]

			# if it doesnt start with either .. www, http or https?
			is_local_url =  !String.starts_with? href, ["www", "http"]

			IO.puts visited_url
			fqdn = extract_fqdn(visited_url)

			cond do
				is_root_url == true ->
					formatted_href = fqdn <> "/" 

				is_relative_url == true ->
					# not sure if good name
					formatted_href =  fqdn <> href

				is_local_url == true ->
					formatted_href = fqdn <> "/" <> href

				true ->
					formatted_href = href
			end

			formatted_href
		end)

		formatted_hrefs
	end

end