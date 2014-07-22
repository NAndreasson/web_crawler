defmodule Crawler.Scheduler do

	def run(url) do
		# spawn 3 crawlers
		(1..3)
			|> Enum.map(fn(_) -> spawn(Crawler.UrlCrawler, :greet, [ self ]) end)
			|> schedule_jobs([], [url], [], 6) # we want to crawl 6 pagess?
	end

	def schedule_jobs(processes, waiting_for_work, urls_to_crawl, urls_crawled, nr_left_to_crawl) do

		# if waiting for work, we have urls to crawl and things to crawl...
		if length(waiting_for_work) > 0 and length(urls_to_crawl) > 0 and nr_left_to_crawl > 0 do
			[ waiting_process | rem_waiting_for_work ] = waiting_for_work
			[ next_url | rem_urls ] = urls_to_crawl

			send waiting_process, {:crawl, next_url, self}

			schedule_jobs(processes, rem_waiting_for_work, rem_urls, [ next_url | urls_crawled ], nr_left_to_crawl - 1)
		end

		receive do
			# wait for the crawler process to say ready, then assign job
			{:ready, pid} when length(urls_to_crawl) > 0 and nr_left_to_crawl > 0 ->
				[ next_url | tail ] = urls_to_crawl
				send pid, {:crawl, next_url, self}

				# continue the scheduling, se the current url as crawled
				schedule_jobs(processes, waiting_for_work, tail, [ next_url | urls_crawled ], nr_left_to_crawl - 1)

			# currently no urls to crawl, wait for them
			{:ready, pid} when length(urls_to_crawl) == 0 and nr_left_to_crawl > 0 ->
				schedule_jobs(processes, [ pid | waiting_for_work ], urls_to_crawl, urls_crawled, nr_left_to_crawl)

			# if we get a ready message and no left to crawl
			{:ready, pid} when nr_left_to_crawl == 0 ->
				# remove and finish up
				send pid, {:shutdown}

				if length(processes) > 1 do 
					schedule_jobs(List.delete(processes, pid), waiting_for_work, urls_to_crawl, urls_crawled, nr_left_to_crawl)
				else
					IO.puts "All done"
					urls_to_crawl
				end
			
			# a crawler is done
			{:answer, hrefs} ->
				# remove hrefs that are already waiting to be crawled or has already been crawled before adding to que
				not_already_crawled = hrefs -- urls_crawled
				not_waiting_to_be_crawled = hrefs -- urls_to_crawl
				not_crawled_or_waiting_to_be_crawled = not_already_crawled ++ not_waiting_to_be_crawled	

				to_crawl = not_crawled_or_waiting_to_be_crawled -- Enum.uniq(not_crawled_or_waiting_to_be_crawled)
				IO.puts "Already crawled"
				IO.puts urls_crawled

				IO.puts "UNIQUE"
				IO.inspect not_crawled_or_waiting_to_be_crawled

				schedule_jobs(processes, waiting_for_work, not_crawled_or_waiting_to_be_crawled, urls_crawled, nr_left_to_crawl)


		end

	end

end