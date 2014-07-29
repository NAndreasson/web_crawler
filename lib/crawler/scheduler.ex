defmodule Crawler.Scheduler do

	def run(url, count) do
		# spawn 3 crawlers
		(1..3)
			|> Enum.map(fn(_) -> spawn(Crawler.UrlCrawler, :greet, [ self ]) end)
			|> schedule_jobs([], %{ start: [ url ] }, count) # we want to crawl 6 pagess?
	end

	def schedule_jobs(processes, waiting_for_work, crawl_map, nr_left_to_crawl) do

		not_yet_crawled = find_not_yet_crawled(crawl_map)


		IO.puts "After returned"

		receive do
			# wait for the crawler process to say ready, then assign job
			{:ready, pid} when length(not_yet_crawled) > 0 and nr_left_to_crawl > 0 ->

				[ next_url | tail ] = not_yet_crawled 
				send pid, {:crawl, next_url, self}

				new_crawl_map = Dict.put(crawl_map, next_url, [])

				# continue the scheduling, se the current url as crawled
				schedule_jobs(processes, waiting_for_work, new_crawl_map, nr_left_to_crawl - 1)

			# currently no urls to crawl, wait for them
			{:ready, pid} when length(not_yet_crawled) == 0 and nr_left_to_crawl > 0 ->
				schedule_jobs(processes, [ pid | waiting_for_work ], crawl_map, nr_left_to_crawl)

			# if we get a ready message and no left to crawl
			{:ready, pid} when nr_left_to_crawl == 0 ->
				# remove and finish up
				send pid, {:shutdown}

				if length(processes) > 1 do 
					schedule_jobs(List.delete(processes, pid), waiting_for_work, crawl_map, nr_left_to_crawl)
				else
					IO.puts "All done"
					crawl_map
				end
			
			# a crawler is done
			{:answer, crawled_url, resulting_urls} ->
				IO.puts "Answer from " <> crawled_url
				new_crawl_map = Dict.put(crawl_map, crawled_url, resulting_urls)
				# remove hrefs that are already waiting to be crawled or has already been crawled before adding to que
				if length(waiting_for_work) > 0 and length(not_yet_crawled) > 0 and nr_left_to_crawl > 0 do
					{new_waiting_for_work, newest_crawl_map, new_nr_left_to_crawl } = 
						assign_work_to_waiting_processes(waiting_for_work, new_crawl_map, nr_left_to_crawl)

					schedule_jobs(processes, new_waiting_for_work, newest_crawl_map, new_nr_left_to_crawl)
				else
					schedule_jobs(processes, waiting_for_work, new_crawl_map, nr_left_to_crawl)
				end
		end

	end

	defp find_not_yet_crawled(crawl_map) do

		# get the values, will retunr something like [ [http://nandreasson.se], []]
		# we want to flatten the result which should leave us with something like [http://nandreasson, facebook etc]
		found_urls = 
			crawl_map
			|> Dict.values
			|> List.flatten

		already_crawled = Dict.keys crawl_map

		# compute the difference between the set of all found urls and those that already has been crawled
		not_yet_crawled_set = Set.difference( Enum.into(found_urls, HashSet.new), Enum.into(already_crawled, HashSet.new) ) 

		HashSet.to_list(not_yet_crawled_set)
	end

	defp assign_work_to_waiting_processes(waiting_for_work, crawl_map, nr_left_to_crawl) do
		not_yet_crawled = find_not_yet_crawled(crawl_map)
		
		if length(waiting_for_work) > 0 and length(not_yet_crawled) > 0 and nr_left_to_crawl > 0 do
			[ waiting_process | rem_waiting_for_work ] = waiting_for_work
			[ next_url | rem_urls ] = not_yet_crawled 

			send waiting_process, {:crawl, next_url, self}

			new_crawl_map = Dict.put(crawl_map, next_url, [])

			assign_work_to_waiting_processes(
				rem_waiting_for_work, new_crawl_map, nr_left_to_crawl - 1
			)
		else
			{waiting_for_work, crawl_map, nr_left_to_crawl}
		end
	end


end