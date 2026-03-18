using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;

public class ABManager : SingletonAutoMono<ABManager>
{
    #region 成员变量/属性

    //由于每次加载AB包，都需要获取主包和依赖包信息
    //故把二者做为成员变量存起来，初始化为null
    private AssetBundle mainAB = null;
    private AssetBundleManifest manifest = null;
    //AB包存储的路径是可能会变的，也把其作为属性存起来
    private string PathUrl
    {
        get
        {
            return Application.streamingAssetsPath + "/";
        }
    }
    //主包名根据平台不同也不一样，结合宏，将其也作为属性存储
    private string MainABName
    {
        get
        {
#if UNITY_IOS   
            return "IOS";
#elif UNITY_ANDROID
            return "Android";
#else 
            return "PC";
#endif
        }
    }

    //用字典来存储加载过的AB包
    private Dictionary<string, AssetBundle> abDic = new Dictionary<string, AssetBundle>();

    #endregion


    #region 通用加载指定AB包(包括其依赖包)的方法
    public void LoadAB(string abName)
    {
        //加载AB包（主包）
        if (mainAB == null)
        {
            mainAB = AssetBundle.LoadFromFile(PathUrl + MainABName);
            manifest = mainAB.LoadAsset<AssetBundleManifest>("AssetBundleManifest");
        }

        //加载所有依赖包
        AssetBundle ab = null;
        string[] strs = manifest.GetAllDependencies(abName);
        
        for (int i = 0; i < strs.Length; i++)
        {
            if (!abDic.ContainsKey(strs[i]))
            {
                ab = AssetBundle.LoadFromFile(PathUrl + strs[i]);
                abDic.Add(strs[i], ab);
            }
        }

        //加载资源来源包
        if(!abDic.ContainsKey(abName))
        {
            ab = AssetBundle.LoadFromFile(PathUrl + abName);
            abDic.Add(abName,ab);
        }
    }
    #endregion

    #region 同步加载方法
    //不指定类型
    public Object LoadRes(string abName, string resName)
    {
        LoadAB(abName);

        //加载资源
        //如果资源是GameObject，那99%是要被拿来实例化，所以直接实例化，否则就返回Object类型
        Object obj = abDic[abName].LoadAsset(resName);
        if(obj is GameObject)
            return Instantiate(obj);
        else
            return obj; 
    }

    //根据type指定类型（Lua常用）
    public Object LoadRes(string abName, string resName ,System.Type type)
    {
        LoadAB(abName);

        Object obj = abDic[abName].LoadAsset(resName,type);
        if(obj is GameObject)
            return Instantiate(obj);
        else
            return obj; 
    }
    
    //根据泛型指定类型（C#常用）
    public T LoadRes<T>(string abName, string resName) where T:Object
    {
        LoadAB(abName);

        T obj = abDic[abName].LoadAsset<T>(resName);
        if(obj is GameObject)
            return Instantiate(obj);
        else
            return obj; 
    }

    #endregion
    
    #region 异步加载方法
    //这里的异步加载，不是指异步加载AB包，而是异步加载AB包中的资源

    //根据名字
    public void LoadResAsync(string abName,string resName,UnityAction<Object> callBack)
    {
        StartCoroutine(ReallyLoadResAsync(abName,resName,callBack));
    }

    private IEnumerator ReallyLoadResAsync(string abName,string resName,UnityAction<Object> callBack)
    {
        LoadAB(abName);

        AssetBundleRequest abr = abDic[abName].LoadAssetAsync(resName);
        yield return abr;

        if(abr.asset is GameObject)
            callBack(Instantiate(abr.asset));
        else
            callBack(abr.asset);
    }

    //根据type
    public void LoadResAsync(string abName,string resName,System.Type type,UnityAction<Object> callBack)
    {
        StartCoroutine(ReallyLoadResAsync(abName,resName,type,callBack));
    }

    private IEnumerator ReallyLoadResAsync(string abName,string resName,System.Type type,UnityAction<Object> callBack)
    {
        LoadAB(abName);

        AssetBundleRequest abr = abDic[abName].LoadAssetAsync(resName,type);
        yield return abr;

        if(abr.asset is GameObject)
            callBack(Instantiate(abr.asset));
        else
            callBack(abr.asset);
    }

    //根据泛型
    public void LoadResAsync<T>(string abName,string resName,UnityAction<Object> callBack)
    {
        StartCoroutine(ReallyLoadResAsync<T>(abName,resName,callBack));
    }

    private IEnumerator ReallyLoadResAsync<T>(string abName,string resName,UnityAction<Object> callBack)
    {
        LoadAB(abName);

        AssetBundleRequest abr = abDic[abName].LoadAssetAsync<T>(resName);
        yield return abr;

        if(abr.asset is GameObject)
            callBack(Instantiate(abr.asset));
        else
            callBack(abr.asset);
    }

    #endregion

    #region 包卸载

    //单个包卸载
    public void UnLoad(string abName)
    {
        if(abDic.ContainsKey(abName))
        {
            abDic[abName].Unload(false);
            abDic.Remove(abName);
        }
    }

    //所有包的卸载
    public void ClearAB()
    {
        AssetBundle.UnloadAllAssetBundles(false);
        abDic.Clear();
        mainAB = null;
        manifest = null;
    }

    #endregion
}
