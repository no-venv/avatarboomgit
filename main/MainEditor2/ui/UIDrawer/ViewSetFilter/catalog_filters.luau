--!nonstrict
type Struct = {
	{
		catagory: string,
		filters: {
			{
				filter_name: string,
				avatar_asset_type: Enum.AvatarAssetType,
				bundle_type: Enum.BundleType,
				offsale: boolean?,
			}
		},
	}
}
local filters: Struct = {

	{
		catagory = "Classic Clothing",
		filters = {
			{
				filter_name = "Shirts",
				avatar_asset_type = Enum.AvatarAssetType.Shirt,
			},
			{
				filter_name = "Pants",
				avatar_asset_type = Enum.AvatarAssetType.Pants,
			},
			{
				filter_name = "T-Shirts",
				avatar_asset_type = Enum.AvatarAssetType.TShirt,
			},
		},
	},
	{
		catagory = "Accessories",
		filters = {
			{
				filter_name = "Head",
				avatar_asset_type = Enum.AvatarAssetType.Hat,
			},
			{
				filter_name = "Face",
				avatar_asset_type = Enum.AvatarAssetType.FaceAccessory,
			},
			{
				filter_name = "Neck",
				avatar_asset_type = Enum.AvatarAssetType.NeckAccessory,
			},
			{
				filter_name = "Shoulders",
				avatar_asset_type = Enum.AvatarAssetType.ShoulderAccessory,
			},
			{
				filter_name = "Front",
				avatar_asset_type = Enum.AvatarAssetType.FrontAccessory,
			},
			{
				filter_name = "Back",
				avatar_asset_type = Enum.AvatarAssetType.BackAccessory,
			},
			{
				filter_name = "Waist",
				avatar_asset_type = Enum.AvatarAssetType.WaistAccessory,
			},
		},
	},
	-- {
	-- 	catagory = "Makeup",
	-- 	filters = {
	-- 		{
	-- 			filter_name = "Face",
	-- 			avatar_asset_type = Enum.AvatarAssetType.FaceMakeup,
	-- 		},
	-- 		{
	-- 			filter_name = "Eye",
	-- 			avatar_asset_type = Enum.AvatarAssetType.EyeMakeup,
	-- 		},
	-- 		{
	-- 			filter_name = "Lip",
	-- 			avatar_asset_type = Enum.AvatarAssetType.LipMakeup,
	-- 		},
	-- 	},
	-- },
	{
		catagory = "Head & Body",
		filters = {
			{
				filter_name = "Hair",
				avatar_asset_type = Enum.AvatarAssetType.HairAccessory,
			},
			{
				filter_name = "Classic Heads",
				avatar_asset_type = Enum.AvatarAssetType.Head,
				bundle_type = Enum.BundleType.BodyParts,
			},
			{
				filter_name = "Classic Faces",
				avatar_asset_type = Enum.AvatarAssetType.Face,
			},
			{
				filter_name = "Dynamic Heads",
				avatar_asset_type = Enum.AvatarAssetType.DynamicHead,
				bundle_type = Enum.BundleType.DynamicHead,
			},
			{
				filter_name = "Bundles",
				bundle_type = Enum.BundleType.BodyParts,
			},
		},
	},
	{
		catagory = "Body Parts",
		filters = {
			{
				filter_name = "Left Arm",
				avatar_asset_type = Enum.AvatarAssetType.LeftArm,
				offsale = true,
			},
			{
				filter_name = "Right Arm",
				avatar_asset_type = Enum.AvatarAssetType.RightArm,
				offsale = true,
			},
			{
				filter_name = "Torso",
				avatar_asset_type = Enum.AvatarAssetType.Torso,
				offsale = true,
			},
			{
				filter_name = "Left Leg",
				avatar_asset_type = Enum.AvatarAssetType.LeftLeg,
				offsale = true,
			},
			{
				filter_name = "Right Leg",
				avatar_asset_type = Enum.AvatarAssetType.RightLeg,
				offsale = true,
			},
		},
	},
	{
		catagory = "Layerd Clothing - Tops",
		filters = {
			{
				filter_name = "T-Shirts",
				avatar_asset_type = Enum.AvatarAssetType.TShirtAccessory,
			},
			{
				filter_name = "Shirts",
				avatar_asset_type = Enum.AvatarAssetType.ShirtAccessory,
			},
			{
				filter_name = "Sweaters",
				avatar_asset_type = Enum.AvatarAssetType.SweaterAccessory,
			},
			{
				filter_name = "Jackets",
				avatar_asset_type = Enum.AvatarAssetType.JacketAccessory,
			},
		},
	},
	{
		catagory = "Layerd Clothing - Bottoms",
		filters = {
			{
				filter_name = "Pants",
				avatar_asset_type = Enum.AvatarAssetType.PantsAccessory,
			},
			{
				filter_name = "Shorts",
				avatar_asset_type = Enum.AvatarAssetType.ShortsAccessory,
			},
			{
				filter_name = "Dresses & Skirts",
				avatar_asset_type = Enum.AvatarAssetType.DressSkirtAccessory,
			},
			{
				filter_name = "Shoes",
				bundle_type = Enum.BundleType.Shoes,
			},
		},
	},
}
return filters
--return {
--	---- {Button Name, AvatarAssetType, BundleType}
--	filters = {
--		{
--			"Classic Clothing";
--			{"Shirts";Enum.AvatarAssetType.Shirt};
--			{"Pants";Enum.AvatarAssetType.Pants};
--			{"T-Shirts",Enum.AvatarAssetType.TShirt}

--		};
--		{
--			"Accessories";
--			{"Head";Enum.AvatarAssetType.Hat},
--			{"Face";Enum.AvatarAssetType.FaceAccessory},
--			{"Neck";Enum.AvatarAssetType.NeckAccessory},
--			{"Shoulders";Enum.AvatarAssetType.ShoulderAccessory},
--			{"Front";Enum.AvatarAssetType.FrontAccessory},
--			{"Back";Enum.AvatarAssetType.BackAccessory},
--			{"Waist";Enum.AvatarAssetType.WaistAccessory}
--		};
--		{
--			"Head & Body";
--			{"Hair";Enum.AvatarAssetType.HairAccessory},
--			--{"Classic Heads";Enum.AvatarAssetType.Head;Enum.BundleType.BodyParts}, Broken
--			{"Classic Faces";Enum.AvatarAssetType.Face},
--			{"Dynamic Heads";Enum.AvatarAssetType.DynamicHead;Enum.BundleType.DynamicHead};
--			{"Bundles";nil;Enum.BundleType.BodyParts};

--		};
--		{
--			"Body Parts";
--			{"Left Arm",Enum.AvatarAssetType.LeftArm};
--			{"Right Arm",Enum.AvatarAssetType.RightArm};
--			{"Torso",Enum.AvatarAssetType.Torso};
--			{"Left Leg",Enum.AvatarAssetType.LeftLeg};
--			{"Right Leg",Enum.AvatarAssetType.RightLeg};
--		};
--		{
--			"Layerd Clothing - Tops";
--			{"T-Shirts";Enum.AvatarAssetType.TShirtAccessory};
--			{"Shirts";Enum.AvatarAssetType.ShirtAccessory};
--			{"Sweaters";Enum.AvatarAssetType.SweaterAccessory};
--			{"Jackets";Enum.AvatarAssetType.JacketAccessory};

--		};
--		{
--			"Layerd Clothing - Bottoms";
--			{"Pants";Enum.AvatarAssetType.PantsAccessory};
--			{"Shorts";Enum.AvatarAssetType.ShortsAccessory};
--			{"Dresses & Skirts";Enum.AvatarAssetType.DressSkirtAccessory};
--			{"Shoes";nil;Enum.BundleType.Shoes};

--		};

--	}

--} :: Struct
