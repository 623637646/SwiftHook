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

Xcode: 11.3.1

[Aspects](https://github.com/steipete/Aspects): 1.4.1

Run Tests Project with release mode (Because Swift is very slow then Objective-C in Debug mode. Refer to:  [Why Swift is so slow in Debug mode](https://stackoverflow.com/questions/61998649/why-swift-is-so-slow-in-debug-mode)


# TestCases

[PerformanceTests.m](../PerformanceTests/PerformanceTests.m)

# Conclusion

* Hook with Befre mode for all instances, SwiftHook is **15 times** faster than Aspects.
* Hook with Instead mode for all instances, SwiftHook is **3.5 times** faster than Aspects.
* Hook with After mode for single instances, SwiftHook is **4.5 times** faster than Aspects.
* Hook with Instead mode for single instances, SwiftHook is **1.9 times** faster than Aspects.

detail:

```
Case: Hook with Befre mode for all instances
100000 times running
Cost 0.000249s for non-hook
Cost 0.596514s for Aspects
Cost 0.039603s for SwiftHook
SwiftHook is 15.06 times faster than Aspects (Hook with Befre mode for all instances)
SwiftHook takes 159.03 times longer than Non-Hook

Case: Hook with Instead mode for all instances
100000 times running
Cost 0.000296s for non-hook
Cost 0.605576s for Aspects
Cost 0.173970s for SwiftHook
SwiftHook is 3.48 times faster than Aspects (Hook with Instead mode for all instances)
SwiftHook takes 587.74 times longer than Non-Hook

Case: Hook with After mode for single instances
100000 times running
Cost 0.000272s for non-hook
Cost 0.594498s for Aspects
Cost 0.130522s for SwiftHook
SwiftHook is 4.55 times faster than Aspects (Hook with After mode for single instances)
SwiftHook takes 480.01 times longer than Non-Hook

Case: Hook with Instead mode for single instances
100000 times running
Cost 0.000267s for non-hook
Cost 0.592294s for Aspects
Cost 0.316831s for SwiftHook
SwiftHook is 1.87 times faster than Aspects (Hook with Instead mode for single instances)
SwiftHook takes 1186.50 times longer than Non-Hook
```
