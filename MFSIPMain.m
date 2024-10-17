function [feature_select, time, objDraw] = MFSIPMain(data_array, tree, alpha, beta)
    data_array = MFSIP_DataHandle(data_array); %% �ȹ�һ��
    [noLeafSampleCell, noLeafLabelCell] = creatSubTablezhIP(data_array, tree);
    internalNodes = tree_InternalNodesIP(tree);
    indexRoot = tree_RootIP(tree); %The root of the tree
    noLeafNode = [internalNodes;indexRoot];
    
    for i = 1:length(noLeafNode)
        ClassLabel = unique(noLeafLabelCell{noLeafNode(i)});
        labelNum(noLeafNode(i)) = length(ClassLabel);
    end
    labelNumMax = max(labelNum); %�����е�d ����������
    
    %%%1 ��ÿ���м�����չ�ɶ���
    for j = 1:length(noLeafNode)
        %%%%����0-3 Y=mi(�ڵ�i����������) * d(��������);
        noLeafLabelCell{noLeafNode(j)} = conversionY01_extendIP(noLeafLabelCell{noLeafNode(j)}, labelNumMax); %extend 2 to [1 0]
    end
    
    %%%2 ��ÿ���м������Ż�
    featureSelectionCell = cell(1, indexRoot);
    tic;
    for k = 1:length(noLeafNode)
        index_k = noLeafNode(k);
        noLeafNode_X = noLeafSampleCell{index_k};
        noLeafNode_Y = noLeafLabelCell{index_k};
        
        if(isempty(noLeafNode_X)) %% ���ݼ�Ϊ��
            continue;
        end
        
        if(k == length(noLeafNode)) % �����Ż�ͼ
            [featureSelectionCell{index_k}, ~, objDrawTemp] = MFSIPFS(noLeafNode_X, noLeafNode_Y, alpha, beta, 1);
            objDraw = objDrawTemp;
        else
            [featureSelectionCell{index_k}, ~] = MFSIPFS(noLeafNode_X, noLeafNode_Y, alpha, beta, 0);
        end
    end
    time = toc;
    feature_select = featureSelectionCell;
end