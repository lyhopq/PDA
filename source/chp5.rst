.. _chp5index:

================
pandas入门
================

在本书的剩下部分，pandas将是我们最敢兴趣的主要库。它包含高级的数据结构和精巧的工具，使得在Python中处理数据非常快速和简单。pandas建造在NumPy之上，它使得以NumPy为中心的应用很容易使用。

作为一点儿背景，早在2008年，我任职于AQR（一个量化投资管理公司）开始构建pandas。当时，我有一组不同的需求，但对于我不能有一个单一的工具来很好的解决： ::

 * 支持自动或明确的数据对齐的带有标签轴的数据结构。这可以防止由数据不对齐引起的常见错误，并可以处理不同来源的不同索引数据。
 * 整合的时间序列功能。
 * 以相同的数据结构来处理时间序列和非时间序列。
 * 支持传递元数据（坐标轴标签）的算数运算和缩减。
 * 灵活处理丢失数据。
 * 在常用的基于数据的数据库（例如基于SQL）中的合并和其它关系操作。

我想要在一个地方能够做上面的所有的事情，最好是在一个非常适合于通用软件开发的语言中。Python是一个很好的候选，但是在那个时候没有一个完整的数据结构和工具的集合来提供这些功能。

在过去的四年里，pandas出乎我的意料，已经成熟到一个非常大的库，可以解决非常广泛的数据处理问题。虽然它的使用范围扩大了，但并没有抛弃我最初所渴望的简单和易使用性。我希望，通过阅读本书后，你会想我一样的发现它是一个必不可少的工具。

在本书的剩余部分，我对pandas使用下面的导入惯例： ::

  In [1]: from pandas import Series, DataFrame
  In [2]: import pandas as pd

pandas数据结构入门
=========================

为了开始使用pandas，你需要熟悉它的两个重要的数据结构： *Series* 和 *DataFrame* 。虽然它们不是没一个问题的通用解决方案，但提供了一个坚实的，易于使用的大多数应用程序的基础。

Series
-----------

Series是一个一维的类似的数组对象，包含一个数组的数据（任何NumPy的数据类型）和一个与数组关联的数据标签，被叫做 *索引* 。最简单的Series是由一个数组的数据构成： ::

  In [4]: obj = Series([4, 7, -5, 3])
  In [5]: obj
  Out[5]:
  0 4
  1 7
  2 -5
  3 3

Seriers的交互式显示的字符窜表示形式是索引在左边，值在右边。因为我们没有给数据指定索引，一个包含整数0到 `N-1` （这里N是数据的长度）的默认索引被创建。 你可以分别的通过它的 `values` 和 `index` 属性来获取Series的数组表示和索引对象： ::

  In [6]: obj.values
  Out[6]: array([ 4, 7, -5, 3])
  In [7]: obj.index
  Out[7]: Int64Index([0, 1, 2, 3])

通常，需要创建一个带有索引来确定没一个数据点的Series： ::

  In [8]: obj2 = Series([4, 7, -5, 3], index=['d', 'b', 'a', 'c'])
  In [9]: obj2
  Out[9]:
  d 4
  b 7
  a -5
  c 3
  In [10]: obj2.index
  Out[10]: Index([d, b, a, c], dtype=object)

与正规的NumPy数组相比，你可以使用索引里的值来选择一个单一值或一个值集： ::

  In [11]: obj2['a']
  Out[11]: -5
  In [12]: obj2['d'] = 6
  In [13]: obj2[['c', 'a', 'd']]
  Out[13]:
  c 3
  a -5
  d 6

NumPy数组操作，例如通过一个布尔数组过滤，纯量乘法，或使用数学函数，将会保持索引和值间的关联： ::

  In [14]: obj2
  Out[14]:
  d 6
  b 7
  a -5
  c 3
  In [15]: obj2[obj2 > 0]   In [16]: obj2 * 2       In [17]: np.exp(obj2)
  Out[15]:                  Out[16]:                Out[17]:
  d 6                       d 12                    d 403.428793
  b 7                       b 14                    b 1096.633158
  c 3                       a -10                   a 0.006738
                            c 6                     c 20.085537

另一种思考的方式是，Series是一个定长的，有序的字典，因为它把索引和值映射起来了。它可以适用于许多期望一个字典的函数： ::

  In [18]: 'b' in obj2
  Out[18]: True
  In [19]: 'e' in obj2
  Out[19]: False

如果你有一些数据在一个Python字典中，你可以通过传递字典来从这些数据创建一个Series： ::

  In [20]: sdata = {'Ohio': 35000, 'Texas': 71000, 'Oregon': 16000, 'Utah': 5000}
  In [21]: obj3 = Series(sdata)
  In [22]: obj3
  Out[22]:
  Ohio 35000
  Oregon 16000
  Texas 71000
  Utah 5000113

只传递一个字典的时候，结果Series中的索引将是排序后的字典的建。

  In [23]: states = ['California', 'Ohio', 'Oregon', 'Texas']
  In [24]: obj4 = Series(sdata, index=states)
  In [25]: obj4
  Out[25]:
  California NaN
  Ohio 35000
  Oregon 16000
  Texas 71000

在这种情况下， **sdata** 中的3个值被放在了合适的位置，但因为没有发现对应于 **'California'** 的值，就出现了 **NaN** （不是一个数），这在pandas中被用来标记数据缺失或 *NA* 值。我使用“missing”或“NA”来表示数度丢失。在pandas中用函数 **isnull** 和 **notnull** 来检测数据丢失： ::

  In [26]: pd.isnull(obj4) In [27]: pd.notnull(obj4)
  Out[26]: Out[27]:
  California True California False
  Ohio False Ohio True
  Oregon False Oregon True
  Texas False Texas True

Series也提供了这些函数的实例方法： ::

  In [28]: obj4.isnull()
  Out[28]:
  California True
  Ohio False
  Oregon False
  Texas False

有关数据丢失的更详细的讨论将在本章的后面进行。

在许多应用中Series的一个重要功能是在算数用算中它会自动对齐不同索引的数据： ::

  In [29]: obj3 In [30]: obj4
  Out[29]: Out[30]:
  Ohio 35000 California NaN
  Oregon 16000 Ohio 35000
  Texas 71000 Oregon 16000
  Utah 5000 Texas 71000
  In [31]: obj3 + obj4
  Out[31]:
  California NaN
  Ohio 70000
  Oregon 32000
  Texas 142000
  Utah NaN

数据对齐被安排为一个独立的话题。

Series对象本身和它的索引都有一个 **name** 属性，它和pandas的其它一些关键功能整合在一起： ::

  In [32]: obj4.name = 'population'
  In [33]: obj4.index.name = 'state'
  In [34]: obj4
  Out[34]:
  state
  California NaN
  Ohio 35000
  Oregon 16000
  Texas 71000
  Name: population

Series的索引可以通过赋值就地更改： ::

  In [35]: obj.index = ['Bob', 'Steve', 'Jeff', 'Ryan']
  In [36]: obj
  Out[36]:
  Bob 4
  Steve 7
  Jeff -5
  Ryan 3

DataFrame
-----------------

一个Datarame表示一个表格，类似电子表格的数据结构，包含一个经过排序的列表集，它们没一个都可以有不同的类型值（数字，字符串，布尔等等）。Datarame有行和列的索引；它可以被看作是一个Series的字典（每个Series共享一个索引）。与其它你以前使用过的（如 **R** 的 **data.frame** )类似Datarame的结构相比，在DataFrame里的面向行和面向列的操作大致是对称的。在底层，数据是作为一个或多个二维数组存储的，而不是列表，字典，或其它一维的数组集合。DataDrame内部的精确细节已超出了本书的范围。

.. ttip::

     因为DataFrame在内部把数据存储为一个二维数组的格式，因此你可以采用分层索引以表格格式来表示高维的数据。分层索引是后面章节的一个主题，并且是pandas中许多更先进的数据处理功能的关键因素。


有很多方法来构建一个DataFrame，但最常用的一个是用一个相等长度列表的字典或NumPy数组： ::

  data = {'state': ['Ohio', 'Ohio', 'Ohio', 'Nevada', 'Nevada'],
          'year': [2000, 2001, 2002, 2001, 2002],
          'pop': [1.5, 1.7, 3.6, 2.4, 2.9]}
  frame = DataFrame(data)

由此产生的DataFrame和Series一样，它的索引会自动分配，并且对列进行了排序： ::
 
  In [38]: frame
  Out[38]:
    pop    state year
  0 1.5     Ohio 2000
  1 1.7     Ohio 2001
  2 3.6     Ohio 2002
  3 2.4   Nevada 2001
  4 2.9   Nevada 2002

如果你设定了一个列的顺序，DataFrame的列将会精确的按照你所传递的顺序排列： ：：

  In [39]: DataFrame(data, columns=['year', 'state', 'pop'])
  Out[39]:
    year state pop
  0 2000  Ohio 1.5
  1 2001  Ohio 1.7
  2 2002  Ohio 3.6
  3 2001 Nevada 2.4
  4 2002 Nevada 2.9

和Series一样，如果你传递了一个行，但不包括在 **data** 中，在结果中它会表示为NA值： ::

  In [40]: frame2 = DataFrame(data, columns=['year', 'state', 'pop', 'debt'],
     ....: index=['one', 'two', 'three', 'four', 'five'])
  In [41]: frame2
  Out[41]:
         year state   pop debt
  one    2000 Ohio    1.5  NaN
  two    2001 Ohio    1.7  NaN
  three  2002 Ohio    3.6  NaN
  four   2001 Nevada  2.4  NaN
  five   2002 Nevada  2.9  NaN

  In [42]: frame2.columns
  Out[42]: Index([year, state, pop, debt], dtype=object)

和Series一样，在DataFrame中的一列可以通过字典记法或属性来检索： ::

  P116

注意，返回的Series包含和DataFrame相同的索引，并它们的 **name** 属性也被正确的设置了。

行也可以使用一些方法通过位置或名字来检索，例如 **ix** 索引成员（field）（更多的将在后面介绍）： ::

  P117

列可以通过赋值来修改。例如，空的 **'debt'** 列可以通过一个纯量或一个数组来赋值： ::

  p117

通过列表或数组给一列赋值时，所赋的值的长度必须和DataFrame的长度相匹配。如果你使用Series来赋值，它会代替在DataFrame中精确匹配的索引的值，并在说有的空洞插入丢失数据
