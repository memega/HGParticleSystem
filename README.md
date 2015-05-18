## HGParticleSystem

A project implementing particle systems based on [Cocos2d-SpriteBuilder](http://cocos2d.spritebuilder.com/). Intended for use with particle systems created by [Particle Editor](http://neobia.com/particleeditor/).

### Installation

Clone the project or download the [latest release](https://github.com/memega/HGParticleSystem/archive/v1.4.zip) from GitHub.

Another way is to add it as a git submodule:

```obj-c
git submodule add https://github.com/memega/HGParticleSystem
```

Then, embed the project:

1. Drag the project for your platform into Xcode workspace, adding it as a subproject (either HGParticleSystem-ios or HGParticleSystem-osx depending on the platform).
2. HGParticleSystem requires an external cocos2d library, so make sure to add a Header Search Path directing to cocos2d in the HGParticleSystem project Build Settings, for example:
![alt text](xcodeHeaderSearchPaths.png "Xcode Header Search Paths setting")
3. Add a Header Search Path directing to HGParticleSystem in your project Build Settings.
4. Add `libHGParticleSystem-ios.a` or `libHGParticleSystem-osx.a` in Link Binary With Libraries section of your project Build Phases.

### Usage

1. Create some `.hgps` files with [Particle Editor](http://neobia.com/particleeditor/).
2. Load `.hgps` files into in-memory cache. The cache pre-populates a number of particle system instances, available for immediate use.

```obj-c
#import "HGParticleSystemCache.h"
#import "HGParticleSystem.h"

[[HGParticleSystemCache sharedCache] addParticleSystemFromFile:@"explosion.hgps"];
HGParticleSystem *system = [[HGParticleSystemCache sharedCache] particleSystemForKey:@"explosion.hgps"];
if (system)
{
    [self addChild:system];
}
```
### Configuration

`HGParticleSystem` also permits programmatic creation and configuration. All property values editable in [Particle Editor](http://neobia.com/particleeditor/) can be changed with code.

```obj-c
HGParticleSystem *system = [[HGParticleSystem alloc] initWithMaxParticles:256];
[system setTexture:image withRect:(CGRect){CGPointZero, texture.contentSizeInPixels}];
[system setValue:@YES forKey:HGLoopingPropertyKey];
[system setPropertyWithConstant:@10 forKey:HGStartSizePropertyKey];
```

Most properties are of dynamic nature and therefore they should be set only via designated `-setProperty:forKey:` method or convenience setters. Some properties as simple values and should be set with `-setValue:forKey` methods.

Please refer to `HGParticleSystem.h` for more information on available property keys and their specifics.

### Limitations

Apple's Metal graphics API rendering is not supported.

### License

This project is licensed under the terms of the [MIT license](http://memega.mit-license.org/).
