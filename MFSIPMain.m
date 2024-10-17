function [feature_select, time, objDraw] = MFSIPMain(data_array, tree, alpha, beta)
    data_array = MFSIP_DataHandle(data_array); %% 先归一化
    [noLeafSampleCell, noLeafLabelCell] = creatSubTablezhIP(data_array, tree);
    internalNodes = tree_InternalNodesIP(tree);
    indexRoot = tree_RootIP(tree); %The root of the tree
    noLeafNode = [internalNodes;indexRoot];
    
    for i = 1:length(noLeafNode)
        ClassLabel = unique(noLeafLabelCell{noLeafNode(i)});
        labelNum(noLeafNode(i)) = length(ClassLabel);
    end
    labelNumMax = max(labelNum); %论文中的d 最大类别数量
    
    %%%1 给每个中间结点扩展成多标记
    for j = 1:length(noLeafNode)
        %%%%懂了0-3 Y=mi(节点i的样本数量) * d(最大类别数);
        noLeafLabelCell{noLeafNode(j)} = conversionY01_extendIP(noLeafLabelCell{noLeafNode(j)}, labelNumMax); %extend 2 to [1 0]
    end
    
    %%%2 给每个中间结点做优化
    featureSelectionCell = cell(1, indexRoot);
    tic;
    for k = 1:length(noLeafNode)
        index_k = noLeafNode(k);
        noLeafNode_X = noLeafSampleCell{index_k};
        noLeafNode_Y = noLeafLabelCell{index_k};
        
        if(isempty(noLeafNode_X)) %% 数据集为空
            continue;
        end
        
        if(k == length(noLeafNode)) % 根结点才画图
            [featureSelectionCell{index_k}, ~, objDrawTemp] = MFSIPFS(noLeafNode_X, noLeafNode_Y, alpha, beta, 1);
            objDraw = objDrawTemp;
        else
            [featureSelectionCell{index_k}, ~] = MFSIPFS(noLeafNode_X, noLeafNode_Y, alpha, beta, 0);
        end
    end
    time = toc;
    feature_select = featureSelectionCell;
end