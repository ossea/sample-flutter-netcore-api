using Microsoft.AspNetCore.Identity;
using Sample.Products.Backend.Entities.Abstract;

namespace Sample.Products.Backend.Entities.Concrete.Tables
{
    public class RegisteredRole:IdentityRole,IEntity
    {
        public RegisteredRole():base()
        {
            
        }
        public RegisteredRole(string role):base(role)
        {

        }
    }
}