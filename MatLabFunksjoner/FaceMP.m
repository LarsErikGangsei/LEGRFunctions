function MP = FaceMP(Surf)
MP = zeros(size(Surf.faces));
for ii = 1:size(MP,1)
    MP(ii,:) = mean(Surf.vertices(Surf.faces(ii,:),:));
end
end