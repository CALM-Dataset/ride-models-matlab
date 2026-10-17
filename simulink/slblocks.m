function blkStruct = slblocks
blkStruct.Name = 'Ride models';
blkStruct.OpenFcn = 'ride_lib';
blkStruct.MaskDisplay = 'disp(''Ride'')';
Browser.Library = 'ride_lib';
Browser.Name = 'Ride models';
blkStruct.Browser = Browser;
end
