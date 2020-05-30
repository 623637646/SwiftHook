# Environments

Device: 

* Model Name:	MacBook Pro
* Model Identifier:	MacBookPro14,3
* Processor Name:	Quad-Core Intel Core i7
* Processor Speed:	2.8 GHz
* Number of Processors:	1
* Total Number of Cores:	4
* L2 Cache (per Core):	256 KB
* L3 Cache:	6 MB
* Hyper-Threading Technology:	Enabled
* Memory:	16 GB

Xcode: 11.4.1
Simulator: iPhone 11 Pro Max (iOS 13.4.1)
[Aspects](https://github.com/steipete/Aspects): 1.4.1

Run Tests Project with release mode (Because Swift is very slow then Objective-C in Debug mode. Refer to:  [Why Swift is so slow in Debug mode](https://stackoverflow.com/questions/61998649/why-swift-is-so-slow-in-debug-mode)


# TestCases

[PerformanceTests.m](../PerformanceTests/PerformanceTests.m)

# Conclusion

* Hook with Before and After mode for all instances, SwiftHook is **13 - 17 times** faster than Aspects.
* Hook with Instead mode for all instances, SwiftHook is **3 - 5 times** faster than Aspects.
* Hook with Before and After mode for specified instances, SwiftHook is **4 - 5 times** faster than Aspects.
* Hook with Instead mode for specified instances, SwiftHook is **2 - 4 times** faster than Aspects.

detail:

```
Case: Hook with After mode for single instances
100000 times running
Cost 0.000374s for non-hook
Cost 0.560002s for Aspects
Cost 0.109990s for SwiftHook
SwiftHook is 5.09 times faster than Aspects (Hook with After mode for single instances)
SwiftHook takes 294.12 times longer than Non-Hook

Case: Hook with Befre mode for all instances
100000 times running
Cost 0.000319s for non-hook
Cost 0.540134s for Aspects
Cost 0.034453s for SwiftHook
SwiftHook is 15.68 times faster than Aspects (Hook with Befre mode for all instances)
SwiftHook takes 108.00 times longer than Non-Hook

Case: Hook with Instead mode for all instances
100000 times running
Cost 0.000243s for non-hook
Cost 0.543941s for Aspects
Cost 0.122922s for SwiftHook
SwiftHook is 4.43 times faster than Aspects (Hook with Instead mode for all instances)
SwiftHook takes 505.96 times longer than Non-Hook

Case: Hook with Instead mode for single instances
100000 times running
Cost 0.000257s for non-hook
Cost 0.525558s for Aspects
Cost 0.170052s for SwiftHook
SwiftHook is 3.09 times faster than Aspects (Hook with Instead mode for single instances)
SwiftHook takes 661.64 times longer than Non-Hook
```
