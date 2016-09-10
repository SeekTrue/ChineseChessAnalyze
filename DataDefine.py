# -*- coding: utf-8 -*-
import math
import pickle
class ChessPosition:
    '记录一方的棋子局势'
    chesstable = {'first_pawn_Red':0,  'second_pawn_Red':3,'third_pawn_Red':6,'forth_pawn_Red':9,'fifth_pawn_Red':12,
                  'Left_cannon_Red':15,'Right_cannon_Red':32,
                  'Left_rook_Red':49,  'Right_rook_Red':66,
                  'Left_knight_Red':83,'Right_knight_Red':91,
                  'Left_minister_Red':99,'Right_minister_Red':103,
                  'Left_Guard_Red':107,'Right_Guard_Red':111,
                  'King_Red':115,
                  'first_pawn_Black':0+119,  'second_pawn_Black':3+119,'third_pawn_Black':6+119,'forth_pawn_Black':9+119,'fifth_pawn_Black':12+119,
                  'Left_cannon_Black':15+119,'Right_cannon_Black':32+119,
                  'Left_rook_Black':49+119,  'Right_rook_Black':66+119,
                  'Left_knight_Black':83+119,'Right_knight_Black':91+119,
                  'Left_minister_Black':99+119,'Right_minister_Black':103+119,
                  'Left_Guard_Black':107+119,'Right_Guard_Black':111+119,
                  'King_Black':115+119}
    def __init__(self):
        self.King_Red = [[0,4],1]#位置 状态 是否被吃掉
        self.Left_Guard_Red=[[0,3],1]
        self.Right_Guard_Red = [[0,5],1]
        self.Left_minister_Red = [[0,2],1]
        self.Right_minister_Red =[[0,6],1]
        self.Left_knight_Red =[[0,1],1]
        self.Right_knight_Red=[[0,7],1]
        self.Left_rook_Red = [[0,0],1]
        self.Right_rook_Red = [[0,8],1]
        self.Left_cannon_Red = [[2,1],1]
        self.Right_cannon_Red = [[2,7],1]
        self.first_pawn_Red = [[3,0],1]
        self.second_pawn_Red =[[3,2],1]
        self.third_pawn_Red =[[3,4],1]
        self.forth_pawn_Red =[[3,6],1]
        self.fifth_pawn_Red=[[3,8],1]

        self.King_Black = [[9-0,8-4],1]#位置 状态 是否被吃掉
        self.Left_Guard_Black=[[9-0,8-3] , 1]
        self.Right_Guard_Black = [[9-0,8-5] , 1]
        self.Left_minister_Black = [[9-0,8-2],1]
        self.Right_minister_Black =[[9-0,8-6],1]
        self.Left_knight_Black =[[9-0,8-1],1]
        self.Right_knight_Black=[[9-0,8-7],1]
        self.Left_rook_Black = [[9-0,8-0],1]
        self.Right_rook_Black = [[9-0,8-8],1]
        self.Left_cannon_Black = [[9-2, 8-1],1]
        self.Right_cannon_Black = [[9-2, 8-7],1]
        self.first_pawn_Black = [[9-3, 8-0],1]
        self.second_pawn_Black =[[9-3, 8-2],1]
        self.third_pawn_Black =[[9-3, 8-4],1]
        self.forth_pawn_Black =[[9-3, 8-6],1]
        self.fifth_pawn_Black=[[9-3, 8-8],1]
        name = '千字文.txt'
        with open(name,'r') as f:
            chars = f.read()
            print(f.close())
        self.names = chars.replace('\n', '')
        self.steps = []

    def Num2Mov(self,num):
        #将数值兑换为子力的移动
        #1：5*3 2*17 2*17 2*8 2*4 2*4 4 119
        names = [['King_Red'],['Left_Guard_Red','Right_Guard_Red'],['Left_minister_Red','Right_minister_Red'],['Left_knight_Red','Right_knight_Red'],['Left_rook_Red','Right_rook_Red'],
                 ['Left_cannon_Red','Right_cannon_Red'],['first_pawn_Red','second_pawn_Red','third_pawn_Red','forth_pawn_Red','fifth_pawn_Red']]
        steplen = [15,15+34,15+34+34,15+34+34+16,15+34+34+16+8,15+34+34+16+8+8,15+34+34+16+8+8+4 ]
        step = []

        if num <steplen[0]:
           j = math.floor(num/3)
           step[0] = names[-1][j]
           step[1] = num%3
           return step
        elif num<steplen[1]:
           temp = (num-steplen[0])
           j = math.floor(temp/17)
           step[0] = names[-2][j]
           step[1] = temp%17
           return step
        elif num<steplen[2]:
           temp = (num-steplen[1])
           j = math.floor(temp/17)
           step[0] = names[-3][j]
           step[1] = temp%17
           return step
        elif num<steplen[3]:
           temp = (num-steplen[2])
           j = math.floor(temp/8)
           step[0] = names[-4][j]
           step[1] = temp%8
           return step
        elif num<steplen[4]:
           temp = (num-steplen[3])
           j = math.floor(temp/4)
           step[0] = names[-5][j]
           step[1] = temp%4
           return step
        elif num<steplen[5]:
           temp = (num-steplen[4])
           j = math.floor(temp/4)
           step[0] = names[-6][j]
           step[1] = temp%4
           return step
        elif num<steplen[6]:
           temp = (num-steplen[5])
           step[0] = names[-7]
           step[1] = temp
           return step
        else:
           num = num - steplen[6]
           for i in range(0,7):
               for j in range(0,len(names[i])):
                 names[i][j] = names[i][j].replace('Red','Black')

           if num <steplen[0]:
               j = math.floor(num/3)
               step[0] = names[-1][j]
               step[1] = num%3
               return step
           elif num<steplen[1]:
               temp = (num-steplen[0])
               j = math.floor(temp/17)
               step[0] = names[-2][j]
               step[1] = temp%17
               return step
           elif num<steplen[2]:
               temp = (num-steplen[1])
               j = math.floor(temp/17)
               step[0] = names[-3][j]
               step[1] = temp%17
               return step
           elif num<steplen[3]:
               temp = (num-steplen[2])
               j = math.floor(temp/8)
               step[0] = names[-4][j]
               step[1] = temp%8
               return step
           elif num<steplen[4]:
               temp = (num-steplen[3])
               j = math.floor(temp/4)
               step[0] = names[-5][j]
               step[1] = temp%4
               return step
           elif num<steplen[5]:
               temp = (num-steplen[4])
               j = math.floor(temp/4)
               step[0] = names[-6][j]
               step[1] = temp%4
               return step
           elif num<steplen[6]:
               temp = (num-steplen[5])
               step[0] = names[-7]
               step[1] = temp
               return step

    def Mov2Num(self,step):
        #将子力的移动换算为数字
        Num = self.chesstable(step[1]) + step[2]
        return Num

    def Move(self,step):
        #根据输入步法，移动子力
        status = getattr(self,step[0]);
        if "pawn_Red"  in step[0]:
            status[0] = self.mov_pawn_Red(step[1],status[0])
            setattr(self,step[0],status)
        if "pawn_Black"  in step[0]:
            status[0] = self.mov_pawn_Black(step[1],status[0])
            setattr(self,step[0],status)
        if "cannon"  in step[0]:
            status[0] = self.mov_cannon(step[1],status[0])
            setattr(self,step[0],status)
        if "rook"  in step[0]:
            status[0] = self.mov_rook(step[1],status[0])
            setattr(self,step[0],status)
        if "knight"  in step[0]:
            status[0] = self.mov_knight(step[1],status[0])
            setattr(self,step[0],status)
        if "Guard"  in step[0]:
            status[0] = self.mov_Guard(step[1],status[0])
            setattr(self,step[0],status)
        if "King"  in step[0]:
            status[0] = self.mov_King(step[1],status[0])
            setattr(self,step[0],status)



    def mov_pawn_Red(self,data,pos):
        #移动红兵
        if data ==0 : # 左移
            pos[1] = pos[1] - 1
        elif data ==1 :# 前进
            pos[0] = pos[0] + 1
        elif data ==2 :# 右移
            pos[1] = pos[1] + 1
        self.check_pos(pos)
        return pos

    def mov_pawn_Black(self,data,pos):
         #移动黑兵
        if data ==0 : # 左移
            pos[1] = pos[1] - 1
        elif data ==1 :# 前进
            pos[0] = pos[0] - 1
        elif data ==2 :# 右移
            pos[1] = pos[1] + 1
        self.check_pos(pos)
        return pos

    def mov_cannon(self,data,pos):
        if data< 9:
            pos[0] = (pos[0] + data + 1)%10
        else:
            data = data - 9
            pos[1] = (pos[1] + data + 1)%9
        self.check_pos(pos)
        return pos

    def mov_rook(self,data,pos):
        if data< 9:
            pos[0] = (pos[0] + data + 1)%10
        else:
            data = data - 9
            pos[1] = (pos[1] + data + 1)%9
        self.check_pos(pos)
        self.check_pos(pos)
        return pos

    def mov_knight(self,data,pos):
        moves = [[2,1],[1,2],[-1,2],[-2,1],[-2,-1],[-1,-2],[1,-2],[2,-1],]
        pos = pos + moves[data]
        self.check_pos(pos)
        return pos

    def mov_minister(self,data,pos):
        moves = [[2,2],[-2,2],[-2,-2],[2,-2],]
        pos = pos + moves[data]
        self.check_pos(pos)
        return pos

    def mov_Guard(self,data,pos):
        moves = [[2,2],[-2,2],[-2,-2],[2,-2],]/2
        pos = pos + moves[data]
        self.check_pos(pos)
        return pos

    def mov_King(self,data,pos):
        moves = [[1,0],[0,1],[-1,0],[0,-1],]
        pos = pos + moves[data]
        self.check_pos(pos)
        return pos

    def check_pos(self,pos):
        #检测是否出现了吃子的行为
        for key in self.chesstable.keys():
            tempos = getattr(self,key)
            if(pos==tempos[0]):#如果吃子
                tempos = 0
                setattr(self,key,tempos)
                break

    def addstep(self,step):
        self.steps.extend(step)
        self.Move(step)

    def savedata(self):
        filename = 'C'
        for i in self.steps:
           num =  self.Mov2Num(i)
           filename += self.names[num]

        with open(filename,'w') as f:
            pickle.dump(self, f)
            print(f.close())
