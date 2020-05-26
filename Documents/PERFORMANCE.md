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

* Hook with Befre mode for all instances, SwiftHook is **16.28** times faster than Aspects.
* Hook with Instead mode for all instances, SwiftHook is **3.48** times faster than Aspects.
* Hook with After mode for single instances, SwiftHook is **3.21** times faster than Aspects.
* Hook with Instead mode for single instances, SwiftHook is **1.66** times faster than Aspects.

detail:

```
Case: Hook with Befre mode for all instances
100000 times running
Cost 0.000260s for non-hook
Cost 0.654195s for Aspects
Cost 0.040192s for SwiftHook
SwiftHook is 16.28 times faster than Aspects (Hook with Befre mode for all instances)
SwiftHook takes 154.59 times longer than Non-Hook

Case: Hook with Instead mode for all instances
100000 times running
Cost 0.000317s for non-hook
Cost 0.612004s for Aspects
Cost 0.176032s for SwiftHook
SwiftHook is 3.48 times faster than Aspects (Hook with Instead mode for all instances)
SwiftHook takes 555.35 times longer than Non-Hook

Case: Hook with After mode for single instances
100000 times running
Cost 0.000298s for non-hook
Cost 0.613204s for Aspects
Cost 0.191130s for SwiftHook
SwiftHook is 3.21 times faster than Aspects (Hook with After mode for single instances)
SwiftHook takes 641.33 times longer than Non-Hook

Case: Hook with Instead mode for single instances
100000 times running
Cost 0.000353s for non-hook
Cost 0.589614s for Aspects
Cost 0.355242s for SwiftHook
SwiftHook is 1.66 times faster than Aspects (Hook with Instead mode for single instances)
SwiftHook takes 1006.41 times longer than Non-Hook
```
