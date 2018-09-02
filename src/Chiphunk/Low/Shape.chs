-- | Description: Shapes manipulations
-- Module provides access to the shapes which define collisions of rigid bodies.
module Chiphunk.Low.Shape
  ( Shape
  , shapeGetBody
  , shapeSetBody
  , shapeGetBB
  , shapeGetSensor
  , shapeSetSensor
  , shapeGetElasticity
  , shapeSetElasticity
  , shapeGetFriction
  , shapeSetFriction
  , shapeGetSurfaceVelocity
  , shapeSetSurfaceVelocity
  , shapeGetCollisionType
  , shapeSetCollisionType
  , ShapeFilter (..)
  , ShapeFilterPtr
  , shapeGetFilter
  , shapeSetFilter
  , shapeGetSpace
  , shapeGetUserData
  , shapeSetUserData
  , shapeFree
  , shapeCacheBB
  , shapeUpdate
  , circleShapeNew
  , segmentShapeNew
  , segmentShapeSetNeighbors
  , polyShapeNew
  , polyShapeNewRaw
  , boxShapeNew
  , boxShapeNew2
  ) where

import Foreign

import Chiphunk.Low.Internal

{# import Chiphunk.Low.Types #}

#include <chipmunk/chipmunk.h>
#include <wrapper.h>

-- | Get the rigid body the shape is attached to.
{# fun unsafe cpShapeGetBody as shapeGetBody {`Shape'} -> `Body' #}

-- | Set the rigid body the shape is attached to. Can only be set when the shape is not added to a space.
{# fun unsafe cpShapeSetBody as shapeSetBody {`Shape', `Body'} -> `()' #}

-- | The bounding box of the shape. Only guaranteed to be valid after 'shapeCacheBB' or 'spaceStep' is called.
-- Moving a body that a shape is connected to does not update its bounding box.
-- For shapes used for queries that aren’t attached to bodies, you can also use 'shapeUpdate'.
{# fun unsafe w_cpShapeGetBB as shapeGetBB {`Shape', alloca- `BB' peek*} -> `()' #}

-- | Get a boolean value if this shape is a sensor or not.
-- Sensors only call collision callbacks, and never generate real collisions.
{# fun unsafe cpShapeGetSensor as shapeGetSensor {`Shape'} -> `Bool' #}

-- | Set a boolean value if this shape is a sensor or not.
{# fun unsafe cpShapeSetSensor as shapeSetSensor {`Shape', `Bool'} -> `()' #}

-- | Get elasticity of the shape.
{# fun unsafe cpShapeGetElasticity as shapeGetElasticity {`Shape'} -> `Double' #}

-- | Set elasticity of the shape.
{# fun unsafe cpShapeSetElasticity as shapeSetElasticity {`Shape', `Double'} -> `()' #}

-- | Get friction coefficient.
{# fun unsafe cpShapeGetFriction as shapeGetFriction {`Shape'} -> `Double' #}

-- | Set friction coefficient.
{# fun unsafe cpShapeSetFriction as shapeSetFriction {`Shape', `Double'} -> `()' #}

-- | Get the surface velocity of the object.
{# fun unsafe w_cpShapeGetSurfaceVelocity as shapeGetSurfaceVelocity {`Shape', alloca- `Vect' peek*} -> `()' #}

-- | Set the surface velocity of the object.
{# fun unsafe cpShapeSetSurfaceVelocity as shapeSetSurfaceVelocity {`Shape', with* %`Vect'} -> `()' #}

-- | Get collision type of this shape.
{# fun unsafe cpShapeGetCollisionType as shapeGetCollisionType {`Shape'} -> `WordPtr' fromIntegral #}

-- | You can assign types to Chipmunk collision shapes that trigger callbacks when objects of certain types touch.
{# fun unsafe cpShapeSetCollisionType as shapeSetCollisionType {`Shape', fromIntegral `WordPtr'} -> `()' #}

-- | Fast collision filtering type that is used to determine if two objects collide
-- before calling collision or query callbacks.
data ShapeFilter = ShapeFilter
  { sfGroup :: !WordPtr
  , sfCategories :: !Word32
  , sfMask :: !Word32
  } deriving Show

instance Storable ShapeFilter where
  sizeOf _    = {# sizeof cpShapeFilter #}
  alignment _ = {# alignof cpShapeFilter #}
  poke p (ShapeFilter g c m) = do
    {# set cpShapeFilter->group #} p      $ fromIntegral g
    {# set cpShapeFilter->categories #} p $ fromIntegral c
    {# set cpShapeFilter->mask #} p       $ fromIntegral m
  peek p = ShapeFilter <$> (fromIntegral <$> {# get cpShapeFilter->group #} p)
                       <*> (fromIntegral <$> {# get cpShapeFilter->categories #} p)
                       <*> (fromIntegral <$> {# get cpShapeFilter->mask #} p)

-- | Pointer to 'ShapeFilter'
{# pointer *cpShapeFilter as ShapeFilterPtr -> ShapeFilter #}

-- | Get the collision filter for this shape.
{# fun unsafe w_cpShapeGetFilter as shapeGetFilter {`Shape', alloca- `ShapeFilter' peek*} -> `()' #}

-- | Set the collision filter for this shape.
{# fun unsafe cpShapeSetFilter as shapeSetFilter {`Shape', with* %`ShapeFilter'} -> `()' #}

-- | Get the 'Space' that shape has been added to.
{# fun unsafe cpShapeGetSpace as shapeGetSpace {`Shape'} -> `Space' #}

-- | Get the user definable data pointer.
{# fun unsafe cpShapeGetUserData as shapeGetUserData {`Shape'} -> `DataPtr' #}

-- | Set a user definable data pointer. If you set this to point at the game object the shapes is for,
-- then you can access your game object from Chipmunk callbacks.
{# fun unsafe cpShapeSetUserData as shapeSetUserData {`Shape', `DataPtr'} -> `()' #}

-- | Deallocates shape.
{# fun unsafe cpShapeFree as shapeFree {`Shape'} -> `()' #}

-- | Synchronizes @shape@ with the body its attached to.
{# fun unsafe w_cpShapeCacheBB as shapeCacheBB
  { `Shape'            -- ^ shape
  , alloca- `BB' peek*
  } -> `()' #}

-- | Sets the position and rotation of the shape
{# fun unsafe w_cpShapeUpdate as shapeUpdate
  { `Shape'            -- ^ @shape@
  , with* %`Transform'
  , alloca- `BB' peek*
  } -> `()' #}

-- | Create new circle-like shape.
{# fun unsafe cpCircleShapeNew as circleShapeNew
  { `Body'        -- ^ The body to attach the circle to.
  , `Double'      -- ^ Radius of the circle.
  , with* %`Vect' -- ^ Offset from the body's center of gravity in body local coordinates.
  } -> `Shape' #}

-- | Create new segment-shaped shape.
{# fun unsafe cpSegmentShapeNew as segmentShapeNew
  { `Body'        -- ^ The body to attach the segment to.
  , with* %`Vect' -- ^ One endpoint.
  , with* %`Vect' -- ^ Another endpoint.
  , `Double'      -- ^ The thickness of the segment.
  } -> `Shape' #}

-- | When you have a number of segment shapes that are all joined together,
-- things can still collide with the “cracks” between the segments.
-- By setting the neighbor segment endpoints you can tell Chipmunk to avoid colliding with the inner parts of the crack.
{# fun unsafe cpSegmentShapeSetNeighbors as segmentShapeSetNeighbors {`Shape', with* %`Vect', with* %`Vect'} -> `()' #}

-- | A convex hull will be calculated from the vertexes automatically.
-- The polygon shape will be created with a radius, increasing the size of the shape.
{# fun unsafe cpPolyShapeNew as polyShapeNew
  { `Body'              -- ^ The body to attach the poly to.
  , withList* `[Vect]'& -- ^ The array of 'Vect' structs.
  , with* %`Transform'  -- ^ The transform that will be applied to every vertex.
  , `Double'            -- ^ Radius.
  } -> `Shape' #}

-- | Alternate constructors for poly shapes. This version does not apply a transform nor does it create a convex hull.
-- Verticies must be provided with a counter-clockwise winding.
{# fun unsafe cpPolyShapeNewRaw as polyShapeNewRaw {`Body', withList* `[Vect]'&, `Double'} -> `Shape' #}

-- | Createa box shape from dimensions.
{# fun unsafe cpBoxShapeNew as boxShapeNew
  { `Body'    -- ^ The body to attach to
  , `Double'  -- ^ Box width
  , `Double'  -- ^ Box height
  , `Double'  -- ^ Radius
  } -> `Shape' #}

-- | Alternative to 'boxShapeNew' using 'BB' to set size.
{# fun unsafe cpBoxShapeNew2 as boxShapeNew2
  { `Body'      -- ^ The body to attach to
  , with* %`BB' -- ^ Shape size
  , `Double'    -- ^ Radius
  } -> `Shape' #}
