using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Shelfie.Models.SearchObjects;
using Shelfie.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;

namespace Shelfie.Services.Services
{
    public abstract class BaseCRUDService<TModel,TSearch,TDbEnitity,TInsert,TUpdate> : BaseService<TModel,TSearch,TDbEnitity> where TModel: class where TSearch:BaseSearchObject where TDbEnitity:class
    {
        public BaseCRUDService(IB220155Context context,IMapper mapper):base(context,mapper)
        {
            
        }

        public virtual async Task<TModel> Insert(TInsert request)
        {
            TDbEnitity entity = Mapper.Map<TDbEnitity>(request);
            await _db.AddAsync(entity);
            await BeforeInsert(request, entity);
            await _db.SaveChangesAsync();

            return Mapper.Map<TModel>(entity);
        }
        public virtual async Task BeforeInsert(TInsert request,TDbEnitity entity)
        {
            if (entity is BaseEntity baseEntity)
            {
                baseEntity.IsActive = true;
            }

            await Task.CompletedTask;
        }
        public virtual async Task BeforeUpdate(TUpdate request, TDbEnitity entity) 
        {
            if (entity is BaseEntity baseEntity)
            {
                baseEntity.ModifiedAt = DateTime.Now;
            }

            await Task.CompletedTask;
        }
        public virtual async Task BeforeDelete(TDbEnitity entity) { }

        public virtual async Task<TModel> Update(int id,TUpdate request)
        {
            var set = _db.Set<TDbEnitity>();

            var entity = set.Find(id);

            Mapper.Map(request, entity);

            await BeforeUpdate(request, entity);

            await _db.SaveChangesAsync();

            return Mapper.Map<TModel>(entity);

            
        }

        public virtual async Task<bool> Delete(int id)
        {
            var set = _db.Set<TDbEnitity>();

            var entity = await set.FindAsync(id);
            if (entity == null)
            {
                return false;
            }

            await BeforeDelete(entity);
            set.Remove(entity);

            await _db.SaveChangesAsync();

            return true;
        }

    }
}
