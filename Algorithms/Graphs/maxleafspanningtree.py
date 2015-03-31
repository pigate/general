import csv
import os
import sys
import copy

os.chdir("C:\Users\Simon\Documents\Python")

def makegraph(adjmatrix,outside):
    graph = []
    adj = open(adjmatrix,'rt')
    out = open(outside,'rt')
    readadj = csv.reader(adj)
    readout = csv.reader(out)
    adjmat = [[]]
    for row in readadj:
        adjrow = []
        row2 = row[0].split('\t')
        for entry in row2:
            adjrow.append(int(entry))
        adjmat.append([0] + adjrow)
    outvec = [0]
    for entry in readout:
        entry = entry[0].split('\t')
        for ent in entry:
            outvec.append(int(ent))
    adjmat[0] = outvec
    for row in range(len(adjmat)):
        for col in range(len(adjmat)):
            if adjmat[row][col] == 1 and [col,row] not in graph:
                graph.append([row,col])
    return graph

def buildtree(graph,nodes):
    isconn = is_connected(graph,nodes)
    if not isconn:
        raise Exception('Graph not connected!')
    forest = []
    used = []
    flag = 1
    while True:
        if flag == 1:
            root = 0
            flag = 0
        else:
            root = degreesequence.index(max(degreesequence))
        tree = []
        leaves = []
        used.append(root)
        for n in range(nodes):
            if n not in used:
                if [n,root] in graph or [root,n] in graph:
                    tree.append([root,n])
                    used.append(n)
                    leaves.append(n)
        while True:
            leavespriority = [priority(leaf,graph,tree) for leaf in range(nodes)]
            if max(leavespriority) == 0:
                break
            leaf = leavespriority.index(max(leavespriority))
            for edge in graph:
                if edge[0] == leaf and edge[1] not in used:
                    used.append(edge[1])
                    leaves.append(edge[1])
                    tree.append(edge)
                if edge[1] == leaf and edge[0] not in used:
                    used.append(edge[0])
                    leaves.append(edge[0])
                    tree.append(edge)
            leaves.remove(leaf)
        forest.append(tree)
        newused = []
        degreesequence = [vertexdegree(n,graph,nodes,used) for n in range(nodes)]
        for n in used:
            degreesequence[n] = 0
        if max(degreesequence) < 3:
            break
    while len(forest) > 1 or len(used) < nodes:
        treelabels = getlabels(forest,nodes)
        for edge in graph:
            i,j = edge
            if treelabels[i] == -1 and treelabels[j] == -1:
                forest.append([[i,j]])
                used += [i,j]
                break
            if treelabels[i] != -1 and treelabels[j] == -1:
                forest[treelabels[i]].append([i,j])
                used.append(j)
                break
            if treelabels[i] == -1 and treelabels[j] != -1:
                forest[treelabels[j]].append([i,j])
                used.append(i)
                break
            if treelabels[i] != treelabels[j]:
                m = treelabels[i]
                n = treelabels[j]
                forest[m] = forest[m] + [[i,j]] + forest[n]
                temp = forest.pop(n)
                break
    return forest[0]

def priority(leaf,graph,tree):
    verts = vertices(tree)
    if leaf not in verts:
        return 0
    newneigh = newneighbors(leaf,graph,verts)
    if len(newneigh) >= 2:
        return 2
    if len(newneigh) == 1:
        y = newneigh[0]
        yneighs = newneighbors(y,graph,verts)
        if len(yneighs) == 2:
            return 1
        if len(yneighs) > 2:
            return 2
    return 0

def newneighbors(leaf,graph,verts):
    neighs = []
    for edge in graph:
        if edge[0] == leaf:
            if edge[1] not in verts:
                neighs.append(edge[1])
        if edge[1] == leaf:
            if edge[0] not in verts:
                neighs.append(edge[0])
    return neighs

def vertices(tree):
    verts = []
    for edge in tree:
        i,j=edge
        if i not in verts:
            verts.append(i)
        if j not in verts:
            verts.append(j)
    return verts

def getlabels(forest,nodes):
    labels = [-1] * nodes
    for i in range(len(forest)):
        for edge in forest[i]:
            j,k = edge
            labels[j] = i
            labels[k] = i
    return labels

def is_connected(graph,nodes):
    if nodes == 0:
        return True
    used = [0]
    unused = range(1,nodes)
    while unused:
        temp = 0
        for edge in graph:
            i,j = edge
            if i in used and j in unused:
                used.append(j)
                unused.remove(j)
                temp = 1
            if j in used and i in unused:
                used.append(i)
                unused.remove(i)
                temp = 1
        if temp == 0 and unused:
            return False
    return True





def vertexdegree(n,graph,nodes,used):
    s = 0
    for i in range(nodes):
        if i not in used:
            if [i,n] in graph or [n,i] in graph:
                s += 1
    return s

def getchildren(tree):
    tree2 = copy.deepcopy(tree)
    children = {}
    used = [0]
    while tree2:
        for edge in tree2:
            if edge[0] in used and edge[1] not in used:
                if edge[0] in children:
                    children[edge[0]].append(edge[1])
                else:
                    children[edge[0]] = [edge[1]]
                used.append(edge[1])
                tree2.remove(edge)
            if edge[1] in used and edge[0] not in used:
                if edge[1] in children:
                    children[edge[1]].append(edge[0])
                else:
                    children[edge[1]] = [edge[0]]
                used.append(edge[0])
                tree2.remove(edge)
    return children

def outputmatrix(tree,nodes): # Verify correctness
    childdict = getchildren(tree)
    outputmat = [[0]*(nodes-1) for _ in range(nodes-1)]
    for key in childdict:
        if key != 0:
            for entry in childdict[key]:
                outputmat[key-1][entry-1] = 1
    return outputmat

def outputvector(tree,nodes):
    childdict = getchildren(tree)
    outputvec = [0] * (nodes-1)
    for entry in childdict[0]:
        outputvec[entry-1] = 1
    return outputvec