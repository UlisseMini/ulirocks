---
title: "Mastering Airstrike with PPO2"
date: 2019-10-03T18:27:26-04:00
draft: false
---

I did it! the first game I've beaten with RL! (using a library)

I'm going to talk through my progress on this problem over around a week and go over everything I tried.


## Attempt 1

Just using the pure `PPO2` example from `stable_baselines` and plugging in the airstrike env

Ran it overnight on my PC and when I got up...

IT WAS SHIT

It hardly improved at all, looking at the reward graph it was crazy! improving sometimes and then getting worse.

## Attempt 2

I found out about some wrappers I can put around an env to improve

After some reading and testing, I used the following wrappers around my env

`WarpEnv` Scale down screen images and grayscale them
`RewardScaler` Downscale the rewards by 255, good for PPO (copied from non stable `baselines`)

Since the input space is so drastically reduced training goes far, far faster (TODO add factor of improvment)

The final result is this **TODO: Add gif**

Still bad, but at least it shoots a lot of ships :)

## Attempt 3

Reading the `baselines` source code, I found that in `retro_wrappers.py` there was a method `make_retro`

This method wrapped the env using a class `StochasticFrameSkip`.

So I copied it over (`stable_baselines` did not have it) and re-ran, here are my results!

**TODO: Add picture of tensorboard graph**

**TODO: Add description of what the colors are**

## Conclusion

I should have spent more time on reading the `baselines` source code (and RL code in general) and less time training

I left the first and second version training overnight twice,
and after all of my improvements It reaches the same score in less then 30 minutes (4 core gtx 1070)

